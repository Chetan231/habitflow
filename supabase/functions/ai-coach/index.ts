import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const { userId, type } = await req.json()

    if (!userId) {
      return new Response(JSON.stringify({ error: 'userId required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Fetch user's habit data
    const today = new Date().toISOString().split('T')[0]
    const weekAgo = new Date(Date.now() - 7 * 86400000).toISOString().split('T')[0]

    const [habitsRes, entriesRes, streaksRes] = await Promise.all([
      supabase.from('habits').select('*').eq('user_id', userId).eq('is_archived', false),
      supabase.from('habit_entries').select('*, habits(name, icon)').eq('user_id', userId).gte('date', weekAgo),
      supabase.from('streaks').select('*, habits(name, icon)').eq('user_id', userId),
    ])

    const habits = habitsRes.data || []
    const entries = entriesRes.data || []
    const streaks = streaksRes.data || []

    const todayEntries = entries.filter(e => e.date === today)
    const completedToday = todayEntries.filter(e => e.completed).length
    const bestStreak = Math.max(0, ...streaks.map(s => s.current_streak))

    let systemPrompt = ''
    let userPrompt = ''

    if (type === 'daily_motivation') {
      systemPrompt = 'You are a fun, energetic habit coach. Give short (2-3 lines) motivational messages in Hinglish (mix of Hindi and English). Be specific to the user data. Use emojis. No generic quotes.'
      userPrompt = `User data today:
- Total habits: ${habits.length}
- Completed today: ${completedToday}/${habits.length}
- Best current streak: ${bestStreak} days
- Habit names: ${habits.map(h => h.name).join(', ')}
Give a personalized motivational message.`
    } else if (type === 'suggestions') {
      systemPrompt = 'You are a habit optimization expert. Analyze data and give 3 specific suggestions. Reply in JSON array format: [{"title": "...", "description": "...", "icon": "emoji"}]. Use Hinglish.'
      userPrompt = `User habits: ${JSON.stringify(habits.map(h => h.name))}
Week entries: ${JSON.stringify(entries.map(e => ({ habit: e.habits?.name, date: e.date, completed: e.completed })))}
Streaks: ${JSON.stringify(streaks.map(s => ({ habit: s.habits?.name, current: s.current_streak })))}
Give 3 specific improvement suggestions.`
    } else if (type === 'pattern') {
      systemPrompt = 'You are a data analyst for habits. Detect patterns and drops. Reply in JSON: {"patterns": ["..."], "drops": ["..."], "insight": "..."}. Use Hinglish.'
      userPrompt = `Analyze this week data: ${JSON.stringify(entries.map(e => ({ habit: e.habits?.name, date: e.date, completed: e.completed })))}`
    }

    const aiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${Deno.env.get('OPENAI_API_KEY')}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: userPrompt },
        ],
        max_tokens: 300,
        temperature: 0.8,
      }),
    })

    const aiData = await aiResponse.json()
    const content = aiData.choices[0].message.content

    // Cache the insight
    await supabase.from('ai_insights').insert({
      user_id: userId,
      insight_type: type,
      content: { text: content },
      date: today,
    })

    return new Response(JSON.stringify({ content, type }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})