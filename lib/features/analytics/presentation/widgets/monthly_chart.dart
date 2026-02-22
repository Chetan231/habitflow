import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/colors.dart';

class MonthlyChart extends StatefulWidget {
  final List<double> monthlyData;
  final String title;
  final bool showAnimation;

  const MonthlyChart({
    super.key,
    required this.monthlyData,
    this.title = 'Monthly Trend',
    this.showAnimation = true,
  });

  @override
  State<MonthlyChart> createState() => _MonthlyChartState();
}

class _MonthlyChartState extends State<MonthlyChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<int>? _showingTooltipOnSpots;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(MonthlyChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.monthlyData != widget.monthlyData) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorder.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LineChart(
                  LineChartData(
                    minX: 1,
                    maxX: widget.monthlyData.length.toDouble(),
                    minY: 0,
                    maxY: 100,
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => AppColors.surface,
                        tooltipBorder: BorderSide(
                          color: AppColors.glassBorder,
                          width: 1,
                        ),
                        tooltipRoundedRadius: 8,
                        tooltipPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        getTooltipItems: (List<LineTooltipItem> touchedSpots) {
                          return touchedSpots.map((LineTooltipItem touchedSpot) {
                            return LineTooltipItem(
                              'Day ${touchedSpot.x.toInt()}\n${touchedSpot.y.toInt()}%',
                              GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            );
                          }).toList();
                        },
                      ),
                      touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
                        if (!event.isInterestedForInteractions ||
                            touchResponse == null ||
                            touchResponse.lineBarSpots == null) {
                          setState(() {
                            _showingTooltipOnSpots?.clear();
                          });
                          return;
                        }
                        final value = touchResponse.lineBarSpots![0].x;
                        
                        if (value == value.toInt().toDouble()) {
                          setState(() {
                            _showingTooltipOnSpots = [value.toInt()];
                          });
                        }
                      },
                    ),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() > 0 && value.toInt() <= widget.monthlyData.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  value.toInt().toString(),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          interval: 25,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                color: AppColors.textTertiary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      horizontalInterval: 25,
                      verticalInterval: 5,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: AppColors.glassBorder.withOpacity(0.1),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: AppColors.glassBorder.withOpacity(0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: widget.monthlyData.asMap().entries.map((entry) {
                          final index = entry.key + 1;
                          final value = entry.value * _animation.value;
                          return FlSpot(index.toDouble(), value);
                        }).toList(),
                        isCurved: true,
                        curveSmoothness: 0.3,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.secondary,
                          ],
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: _showingTooltipOnSpots?.contains(spot.x.toInt()) == true ? 6 : 4,
                              color: AppColors.primary,
                              strokeWidth: 2,
                              strokeColor: AppColors.background,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.3),
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Trend analysis
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrendItem(
                'Average',
                '${widget.monthlyData.isEmpty ? 0 : (widget.monthlyData.reduce((a, b) => a + b) / widget.monthlyData.length).toInt()}%',
                _getTrendIcon(widget.monthlyData),
                _getTrendColor(widget.monthlyData),
              ),
              _buildTrendItem(
                'Best',
                '${widget.monthlyData.isEmpty ? 0 : widget.monthlyData.reduce((a, b) => a > b ? a : b).toInt()}%',
                Icons.trending_up,
                AppColors.success,
              ),
              _buildTrendItem(
                'Consistency',
                '${_calculateConsistency()}%',
                Icons.insights,
                AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTrendIcon(List<double> data) {
    if (data.length < 2) return Icons.trending_flat;
    
    final firstHalf = data.take(data.length ~/ 2).reduce((a, b) => a + b) / (data.length ~/ 2);
    final secondHalf = data.skip(data.length ~/ 2).reduce((a, b) => a + b) / (data.length - data.length ~/ 2);
    
    if (secondHalf > firstHalf + 5) return Icons.trending_up;
    if (secondHalf < firstHalf - 5) return Icons.trending_down;
    return Icons.trending_flat;
  }

  Color _getTrendColor(List<double> data) {
    if (data.length < 2) return AppColors.textSecondary;
    
    final firstHalf = data.take(data.length ~/ 2).reduce((a, b) => a + b) / (data.length ~/ 2);
    final secondHalf = data.skip(data.length ~/ 2).reduce((a, b) => a + b) / (data.length - data.length ~/ 2);
    
    if (secondHalf > firstHalf + 5) return AppColors.success;
    if (secondHalf < firstHalf - 5) return AppColors.error;
    return AppColors.textSecondary;
  }

  int _calculateConsistency() {
    if (widget.monthlyData.isEmpty) return 0;
    
    final nonZeroDays = widget.monthlyData.where((value) => value > 0).length;
    return ((nonZeroDays / widget.monthlyData.length) * 100).toInt();
  }

  Widget _buildTrendItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}