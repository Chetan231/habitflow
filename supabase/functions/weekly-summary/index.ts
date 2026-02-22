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

    const { userId } = await req.json()

    if (!userId) {
      return new Response(JSON.stringify({ error: 'userId required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // Get last 7 days data
    const today = new Date()
    const weekAgo = new Date(today.getTime() - 7 * 86400000)
    const todayStr = today.toISOString().split('T')[0]
    const weekAgoStr = weekAgo.toISOString().split('T')[0]

    const [habitsRes, entriesRes, streaksRes] = await Promise.all([
      supabase.from('habits').select('*').eq('user_id', userId).eq('is_archived', false),
      supabase.from('habit_entries')
        .select('*, habits(name, icon)')
        .eq('user_id', userId)
        .gte('date', weekAgoStr)
        .lte('date', todayStr),
      supabase.from('streaks').select('*, habits(name, icon)').eq('user_id', userId),
    ])

    const habits = habitsRes.data || []
    const entries = entriesRes.data || []
    const streaks = streaksRes.data || []

    // Calculate weekly stats
    const totalPossible = habits.length * 7
    const totalCompleted = entries.filter(e => e.completed).length
    const completionRate = totalPossible > 0 ? Math.round((totalCompleted / totalPossible) * 100) : 0

    // Group entries by habit
    const habitStats = habits.map(habit => {
      const habitEntries = entries.filter(e => e.habit_id === habit.id)
      const completedCount = habitEntries.filter(e => e.completed).length
      const streak = streaks.find(s => s.habit_id === habit.id)?.current_streak || 0
      return {
        name: habit.name,
        icon: habit.icon,
        completedCount,
        completionRate: Math.round((completedCount / 7) * 100),
        streak
      }
    })

    // Find best and worst habits
    const sortedHabits = habitStats.sort((a, b) => b.completionRate - a.completionRate)
    const bestHabit = sortedHabits[0] || null
    const worstHabit = sortedHabits[sortedHabits.length - 1] || null

    // Calculate weekly score (0-100)
    const score = Math.min(100, Math.round(
      (completionRate * 0.7) + 
      (streaks.reduce((acc, s) => acc + Math.min(s.current_streak, 7), 0) / (habits.length * 7) * 100 * 0.3)
    ))

    const systemPrompt = 'You are a habit coach analyzing weekly performance. Generate a JSON response with these exact keys: {"summary": "2-3 line summary in Hinglish with emojis", "bestHabit": "praise for best habit", "worstHabit": "gentle advice for improvement", "tip": "one actionable tip"}. Be encouraging and specific to the data.'

    const userPrompt = `Weekly Analysis:
- Total habits: ${habits.length}
- Completion rate: ${completionRate}%
- Total completed: ${totalCompleted}/${totalPossible}
- Score: ${score}/100

Best habit: ${bestHabit ? `${bestHabit.name} (${bestHabit.completionRate}%)` : 'None'}
Worst habit: ${worstHabit ? `${worstHabit.name} (${worstHabit.completionRate}%)` : 'None'}

Habit details: ${JSON.stringify(habitStats)}

Generate encouraging weekly summary with specific insights.`

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
        max_tokens: 400,
        temperature: 0.7,
      }),
    })

    const aiData = await aiResponse.json()
    let aiContent

    try {
      aiContent = JSON.parse(aiData.choices[0].message.content)
    } catch {
      // Fallback if AI doesn't return valid JSON
      aiContent = {
        summary: aiData.choices[0].message.content,
        bestHabit: bestHabit ? `Great work on ${bestHabit.name}! 🎉` : 'Keep building your habits! 💪',
        worstHabit: worstHabit ? `Try to improve ${worstHabit.name} next week 💡` : 'Focus on consistency 🎯',
        tip: 'Start small, stay consistent! 🚀'
      }
    }

    // Prepare response data
    const responseData = {
      summary: aiContent.summary,
      bestHabit: bestHabit,
      worstHabit: worstHabit,
      score: score,
      completionRate: completionRate,
      totalCompleted: totalCompleted,
      totalPossible: totalPossible,
      habitStats: habitStats,
      aiInsights: {
        bestHabitPraise: aiContent.bestHabit,
        worstHabitAdvice: aiContent.worstHabit,
        tip: aiContent.tip
      },
      weekRange: {
        start: weekAgoStr,
        end: todayStr
      }
    }

    // Cache the weekly summary
    await supabase.from('ai_insights').insert({
      user_id: userId,
      insight_type: 'weekly_summary',
      content: responseData,
      date: todayStr,
    })

    return new Response(JSON.stringify(responseData), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})