// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import '../controller/appliance_controller.dart';
// import '../service/applince_service.dart';
//
// class ApplianceDetailView extends StatelessWidget {
//   const ApplianceDetailView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(ApplianceController());
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return Scaffold(
//       body: Obx(() => controller.isLoading.value
//           ? const Center(child: CircularProgressIndicator())
//           : CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200,
//             pinned: true,
//             elevation: 0,
//             flexibleSpace: FlexibleSpaceBar(
//               title: Text(
//                 controller.appliance.value.applianceInfo.appliance,
//                 style: TextStyle(
//                   color: colorScheme.onPrimary,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               background: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       colorScheme.primary,
//                       colorScheme.primaryContainer,
//                     ],
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     Positioned.fill(
//                       child: Opacity(
//                         opacity: 0.1,
//                         child: Image.asset(
//                           'assets/images/energy_pattern.png',
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     Center(
//                       child: Hero(
//                         tag: 'appliance-${controller.appliance.value.id}',
//                         child: Icon(
//                           _getApplianceIcon(
//                             controller.appliance.value.applianceInfo.appliance,
//                           ),
//                           size: 80,
//                           color: colorScheme.onPrimary,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 24),
//                   _buildEnergyOverview(context, controller),
//                   const SizedBox(height: 32),
//                   _buildCurrentStats(context, controller),
//                   const SizedBox(height: 32),
//                   _buildPowerConsumptionChart(context, controller),
//                   const SizedBox(height: 32),
//                   _buildUsageTimeline(context, controller),
//                   const SizedBox(height: 32),
//                   _buildEfficiencyCard(context, controller),
//                   const SizedBox(height: 32),
//                   _buildScheduleSettings(context, controller),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       )),
//
//     );
//   }
//
//   Widget _buildEnergyOverview(BuildContext context, ApplianceController controller) {
//     final colorScheme = Theme.of(context).colorScheme;
//
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(Icons.bolt, color: colorScheme.primary),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Energy Overview',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: _buildOverviewItem(
//                     context,
//                     'Rated Power',
//                     controller.appliance.value.applianceInfo.ratedPower,
//                     Icons.power,
//                     colorScheme.primary,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildOverviewItem(
//                     context,
//                     'Active Energy',
//                     '${controller.appliance.value.activeEnergy} Wh',
//                     Icons.energy_savings_leaf,
//                     Colors.green,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ).animate().fadeIn().slideY(begin: 0.2, end: 0);
//   }
//
//   Widget _buildOverviewItem(
//       BuildContext context,
//       String title,
//       String value,
//       IconData icon,
//       Color color,
//       ) {
//     return Column(
//       children: [
//         Icon(icon, color: color, size: 32),
//         const SizedBox(height: 8),
//         Text(
//           title,
//           style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//             color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           value,
//           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildCurrentStats(BuildContext context, ApplianceController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.only(left: 8.0, bottom: 16.0),
//           child: Text(
//             'Current Readings',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//         ),
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 context,
//                 'Current',
//                 '${controller.appliance.value.current}A',
//                 Icons.electric_bolt,
//                 Colors.orange,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: _buildStatCard(
//                 context,
//                 'Voltage',
//                 '${controller.appliance.value.voltage}V',
//                 Icons.power_input,
//                 Colors.blue,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: _buildStatCard(
//                 context,
//                 'Time On',
//                 '${_formatTimeOn(controller.appliance.value.timeOn)}',
//                 Icons.timer,
//                 Colors.purple,
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: _buildStatCard(
//                 context,
//                 'Last Reading',
//                 DateFormat('MMM d, h:mm a').format(
//                   controller.appliance.value.readingTimeStamp,
//                 ),
//                 Icons.history,
//                 Colors.teal,
//               ),
//             ),
//           ],
//         ),
//       ],
//     ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
//   }
//
//   Widget _buildStatCard(
//       BuildContext context,
//       String title,
//       String value,
//       IconData icon,
//       Color color,
//       ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                     color: Theme.of(context)
//                         .colorScheme
//                         .onSurface
//                         .withValues(alpha: 0.7),
//                   ),
//                 ),
//                 Icon(icon, color: color, size: 24),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 value,
//                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPowerConsumptionChart(
//       BuildContext context,
//       ApplianceController controller,
//       ) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.show_chart,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Power Consumption',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Obx(() {
//               if (controller.powerReadings.isEmpty) {
//                 return const SizedBox(
//                   height: 200,
//                   child: Center(child: Text('No data available')),
//                 );
//               }
//
//               return SizedBox(
//                 height: 250,
//                 child: LineChart(
//                   LineChartData(
//                     gridData: FlGridData(
//                       show: true,
//                       drawVerticalLine: false,
//                       horizontalInterval: 50,
//                       getDrawingHorizontalLine: (value) {
//                         return FlLine(
//                           color:
//                           Theme.of(context).dividerColor.withValues(alpha: 0.3),
//                           strokeWidth: 1,
//                         );
//                       },
//                     ),
//                     titlesData: FlTitlesData(
//                       leftTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           reservedSize: 40,
//                           getTitlesWidget: (value, meta) {
//                             return Text(
//                               value.toInt().toString(),
//                               style: TextStyle(
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .onSurface
//                                     .withValues(alpha: 0.6),
//                                 fontSize: 10,
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       rightTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       topTitles: AxisTitles(
//                         sideTitles: SideTitles(showTitles: false),
//                       ),
//                       bottomTitles: AxisTitles(
//                         sideTitles: SideTitles(
//                           showTitles: true,
//                           reservedSize: 30,
//                           interval: 4,
//                           getTitlesWidget: (value, meta) {
//                             if (value.toInt() >= controller.powerReadings.length ||
//                                 value.toInt() % 4 != 0) {
//                               return const SizedBox.shrink();
//                             }
//                             final reading = controller.powerReadings[value.toInt()];
//                             return Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Text(
//                                 DateFormat('h a').format(reading.timestamp),
//                                 style: TextStyle(
//                                   color: Theme.of(context)
//                                       .colorScheme
//                                       .onSurface
//                                       .withValues(alpha: 0.6),
//                                   fontSize: 10,
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     borderData: FlBorderData(
//                       show: true,
//                       border: Border(
//                         bottom: BorderSide(
//                           color: Theme.of(context).dividerColor,
//                           width: 1,
//                         ),
//                         left: BorderSide(
//                           color: Theme.of(context).dividerColor,
//                           width: 1,
//                         ),
//                         right: BorderSide(
//                           color: Colors.transparent,
//                         ),
//                         top: BorderSide(
//                           color: Colors.transparent,
//                         ),
//                       ),
//                     ),
//                     lineBarsData: [
//                       LineChartBarData(
//                         spots: List.generate(
//                           controller.powerReadings.length,
//                               (index) => FlSpot(
//                             index.toDouble(),
//                             controller.powerReadings[index].power,
//                           ),
//                         ),
//                         isCurved: true,
//                         color: Theme.of(context).colorScheme.primary,
//                         barWidth: 3,
//                         dotData: FlDotData(
//                           show: false,
//                         ),
//                         belowBarData: BarAreaData(
//                           show: true,
//                           color: Theme.of(context)
//                               .colorScheme
//                               .primary
//                               .withValues(alpha: 0.2),
//                         ),
//                       ),
//                     ],
//                     lineTouchData: LineTouchData(
//                       touchTooltipData: LineTouchTooltipData(
//                         tooltipBorder: BorderSide(
//                           color: Theme.of(context).colorScheme.surface,
//                         ),
//                         tooltipRoundedRadius: 8,
//                         getTooltipItems: (touchedSpots) {
//                           return touchedSpots.map((touchedSpot) {
//                             final reading =
//                             controller.powerReadings[touchedSpot.x.toInt()];
//                             return LineTooltipItem(
//                               '${reading.power.toStringAsFixed(1)} W\n',
//                               TextStyle(
//                                 color: Theme.of(context).colorScheme.onSurface,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               children: [
//                                 TextSpan(
//                                   text: DateFormat('MMM d, h:mm a')
//                                       .format(reading.timestamp),
//                                   style: TextStyle(
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .onSurface
//                                         .withValues(alpha: 0.7),
//                                     fontWeight: FontWeight.normal,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ],
//                             );
//                           }).toList();
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
//   }
//
//   Widget _buildUsageTimeline(BuildContext context, ApplianceController controller) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.timeline,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Usage Timeline',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Obx(() {
//               if (controller.timelineData.isEmpty) {
//                 return const Center(
//                   child: Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Text('No timeline data available'),
//                   ),
//                 );
//               }
//
//               return ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: min(5, controller.timelineData.length),
//                 itemBuilder: (context, index) {
//                   final entry = controller.timelineData[index];
//                   return _buildTimelineItem(context, entry, index);
//                 },
//               );
//             }),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
//   }
//
//   Widget _buildTimelineItem(
//       BuildContext context,
//       TimelineEntry entry,
//       int index,
//       ) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final isLast = index == 4;
//
//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 24,
//             child: Column(
//               children: [
//                 Container(
//                   width: 12,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: colorScheme.primary,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//                 if (!isLast)
//                   Expanded(
//                     child: Container(
//                       width: 2,
//                       color: colorScheme.primary.withValues(alpha: 0.3),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     entry.event,
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     '${entry.value} • ${DateFormat('MMM d, h:mm a').format(entry.timestamp)}',
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: colorScheme.onSurface.withValues(alpha: 0.7),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildEfficiencyCard(BuildContext context, ApplianceController controller) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.eco,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Efficiency Rating',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   flex: 3,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Obx(() => Text(
//                         controller.getEfficiencyStatus(),
//                         style:
//                         Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: controller.getEfficiencyColor(),
//                         ),
//                       )),
//                       const SizedBox(height: 8),
//                       Obx(() => Text(
//                         'Avg: ${controller.getAveragePower().toStringAsFixed(1)} W',
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       )),
//                       const SizedBox(height: 4),
//                       Obx(() => Text(
//                         'Max: ${controller.getMaxPower().toStringAsFixed(1)} W',
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       )),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   flex: 2,
//                   child: Obx(() => _buildEfficiencyGauge(
//                     context,
//                     controller.getEfficiencyColor(),
//                     controller.getEfficiencyPercentage(),
//                   )),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0);
//   }
//
//   Widget _buildEfficiencyGauge(
//       BuildContext context,
//       Color color,
//       double percentage,
//       ) {
//     return SizedBox(
//       height: 100,
//       width: 100,
//       child: Stack(
//         children: [
//           Center(
//             child: SizedBox(
//               height: 80,
//               width: 80,
//               child: CircularProgressIndicator(
//                 value: percentage,
//                 strokeWidth: 10,
//                 backgroundColor:
//                 Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
//                 valueColor: AlwaysStoppedAnimation<Color>(color),
//               ),
//             ),
//           ),
//           Center(
//             child: Text(
//               '${(percentage * 100).toInt()}%',
//               style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildScheduleSettings(BuildContext context, ApplianceController controller) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(
//                   Icons.schedule,
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Schedule & Settings',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Obx(() => ListTile(
//               contentPadding: EdgeInsets.zero,
//               title: const Text('Daily Schedule'),
//               subtitle: Text(
//                 controller.schedule.value.enabled
//                     ? '${_formatTimeOfDay(controller.schedule.value.startTime)} - ${_formatTimeOfDay(controller.schedule.value.endTime)}'
//                     : 'Not scheduled',
//               ),
//               trailing: Switch(
//                 value: controller.schedule.value.enabled,
//                 onChanged: (value) {
//                   controller.toggleSchedule(value);
//                 },
//                 activeColor: Theme.of(context).colorScheme.primary,
//               ),
//             )),
//             const Divider(),
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               title: const Text('Power Saving Mode'),
//               subtitle: const Text('Automatically adjust power usage'),
//               trailing: Obx(() => Switch(
//                 value: controller.powerSavingEnabled.value,
//                 onChanged: (value) {
//                   controller.togglePowerSavingMode(value);
//                 },
//                 activeColor: Theme.of(context).colorScheme.primary,
//               )),
//             ),
//           ],
//         ),
//       ),
//     ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0);
//   }
//
//   IconData _getApplianceIcon(String appliance) {
//     switch (appliance.toLowerCase()) {
//       case 'television':
//       case 'tv':
//         return Icons.tv;
//       case 'refrigerator':
//       case 'refridgerator':
//         return Icons.kitchen;
//       case 'air conditioner':
//       case 'ac':
//         return Icons.ac_unit;
//       case 'washing machine':
//         return Icons.local_laundry_service;
//       case 'microwave':
//         return Icons.microwave;
//       case 'water heater':
//         return Icons.hot_tub;
//       case 'light':
//       case 'lamp':
//         return Icons.lightbulb;
//       case 'fan':
//         return Icons.air;
//       case 'computer':
//       case 'pc':
//         return Icons.computer;
//       default:
//         return Icons.electrical_services;
//     }
//   }
//
//   String _formatTimeOn(String minutes) {
//     // Convert string to double
//     final double mins = double.tryParse(minutes) ?? 0.0;
//
//     // Calculate hours and remaining minutes
//     final int hours = mins ~/ 60;
//     final int remainingMins = (mins % 60).round();
//
//     if (hours > 0) {
//       return '$hours hr ${remainingMins > 0 ? '$remainingMins min' : ''}';
//     } else {
//       return '$remainingMins min';
//     }
//   }
//
//   String _formatTimeOfDay(TimeOfDay time) {
//     final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
//     final minute = time.minute.toString().padLeft(2, '0');
//     final period = time.period == DayPeriod.am ? 'AM' : 'PM';
//     return '$hour:$minute $period';
//   }
//
//   String _getDayLabel(int day) {
//     const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
//     return days[day];
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../rooms/controller/room_controller.dart';
import '../../rooms/model/appliance.dart';

class ApplianceDetailView extends StatelessWidget {
  const ApplianceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final roomController = Get.find<RoomController>();
    final appliance = Get.arguments as Appliance;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(appliance.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditApplianceDialog(context, appliance, roomController),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Device status card
              _buildStatusCard(context, appliance, roomController)
                  .animate().fadeIn().slideY(),

              const SizedBox(height: 24),

              // Energy usage section
              Text(
                'Energy Usage',
                style: theme.textTheme.titleLarge,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              _buildEnergyUsageCard(context, appliance)
                  .animate().fadeIn(delay: 300.ms).slideY(),

              const SizedBox(height: 24),

              // Usage history section
              Text(
                'Usage History',
                style: theme.textTheme.titleLarge,
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 16),

              _buildUsageHistoryCard(context, appliance)
                  .animate().fadeIn(delay: 500.ms).slideY(),

              const SizedBox(height: 24),

              // Device info section
              Text(
                'Device Information',
                style: theme.textTheme.titleLarge,
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 16),

              _buildDeviceInfoCard(context, appliance)
                  .animate().fadeIn(delay: 700.ms).slideY(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(
      BuildContext context,
      Appliance appliance,
      RoomController controller,
      ) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIconData(appliance.iconName),
                        color: theme.colorScheme.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appliance.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          appliance.type.capitalize!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: appliance.isOn,
                  onChanged: (value) {
                    final updatedAppliance = appliance.copyWith(isOn: value);
                    controller.updateAppliance(updatedAppliance);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusItem(
                  context,
                  'Power',
                  '${appliance.power.toStringAsFixed(1)} W',
                  Icons.bolt,
                  Colors.orange,
                ),
                _buildStatusItem(
                  context,
                  'Voltage',
                  '${appliance.voltage.toStringAsFixed(1)} V',
                  Icons.electric_bolt,
                  Colors.blue,
                ),
                _buildStatusItem(
                  context,
                  'Current',
                  '${appliance.current.toStringAsFixed(2)} A',
                  Icons.speed,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status',
                  style: theme.textTheme.bodyMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: appliance.isOn
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        appliance.isOn ? Icons.check_circle : Icons.cancel,
                        color: appliance.isOn ? Colors.green : Colors.grey,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        appliance.isOn ? 'On' : 'Off',
                        style: TextStyle(
                          color: appliance.isOn ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last Updated',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  DateFormat('MMM d, yyyy h:mm a').format(appliance.lastUpdated),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyUsageCard(BuildContext context, Appliance appliance) {
    final theme = Theme.of(context);

    // Mock data for energy usage
    final dailyUsage = 1.2; // kWh
    final monthlyCost = 5.4; // $
    final yearlyEmissions = 18.7; // kg CO2

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Usage',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildEnergyMetric(
                  context,
                  'Energy',
                  '$dailyUsage kWh',
                  Icons.bolt,
                  Colors.orange,
                ),
                _buildEnergyMetric(
                  context,
                  'Cost',
                  '\$$monthlyCost',
                  Icons.attach_money,
                  Colors.green,
                ),
                _buildEnergyMetric(
                  context,
                  'CO₂',
                  '$yearlyEmissions kg',
                  Icons.cloud,
                  Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hourly Usage',
                  style: theme.textTheme.titleSmall,
                ),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Today',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()} W',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final hour = value.toInt();
                          return Text(
                            '$hour:00',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        FlSpot(0, 10),
                        FlSpot(4, 20),
                        FlSpot(8, 35),
                        FlSpot(12, 40),
                        FlSpot(16, 25),
                        FlSpot(20, 15),
                        FlSpot(24, 10),
                      ],
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageHistoryCard(BuildContext context, Appliance appliance) {
    final theme = Theme.of(context);

    // Mock data for usage history
    final usageHistory = [
      {'date': 'Mon', 'usage': 1.2},
      {'date': 'Tue', 'usage': 1.5},
      {'date': 'Wed', 'usage': 1.3},
      {'date': 'Thu', 'usage': 1.7},
      {'date': 'Fri', 'usage': 1.9},
      {'date': 'Sat', 'usage': 2.1},
      {'date': 'Sun', 'usage': 1.8},
    ];

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Usage',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: 'This Week',
                  items: [
                    DropdownMenuItem(
                      value: 'This Week',
                      child: Text('This Week'),
                    ),
                    DropdownMenuItem(
                      value: 'Last Week',
                      child: Text('Last Week'),
                    ),
                    DropdownMenuItem(
                      value: 'Last Month',
                      child: Text('Last Month'),
                    ),
                  ],
                  onChanged: (value) {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 3,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      //tooltipBgColor: theme.colorScheme.surface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${usageHistory[groupIndex]['date']}: ${rod.toY.toStringAsFixed(1)} kWh',
                          TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            usageHistory[value.toInt()]['date'] as String,
                            style: theme.textTheme.bodySmall,
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()} kWh',
                            style: theme.textTheme.bodySmall,
                          );
                        },
                        reservedSize: 40,
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: usageHistory.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data['usage'] as double,
                          color: theme.colorScheme.primary,
                          width: 20,
                          borderRadius: BorderRadius.circular(4),
                          backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: 3,
                            color: theme.colorScheme.surfaceVariant,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildUsageStat(
                  context,
                  'Total',
                  '11.5 kWh',
                  Icons.bolt,
                ),
                _buildUsageStat(
                  context,
                  'Average',
                  '1.64 kWh/day',
                  Icons.trending_up,
                ),
                _buildUsageStat(
                  context,
                  'Cost',
                  '\$1.73/day',
                  Icons.attach_money,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard(BuildContext context, Appliance appliance) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Device Name', appliance.name),
            const Divider(height: 24),
            _buildInfoRow(context, 'Type', appliance.type.capitalize!),
            const Divider(height: 24),
            _buildInfoRow(context, 'Status', appliance.status),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              'Last Updated',
              DateFormat('MMM d, yyyy h:mm a').format(appliance.lastUpdated),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement device calibration
                  Get.snackbar(
                    'Calibration',
                    'Device calibration started',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                icon: Icon(Icons.tune),
                label: Text('Calibrate Device'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyMetric(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageStat(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      ) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showEditApplianceDialog(
      BuildContext context,
      Appliance appliance,
      RoomController controller,
      ) {
    final nameController = TextEditingController(text: appliance.name);

    Get.dialog(
      AlertDialog(
        title: Text('Edit Device'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Device Name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.defaultDialog(
                title: 'Delete Device',
                middleText: 'Are you sure you want to delete this device?',
                textConfirm: 'Delete',
                textCancel: 'Cancel',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  controller.deleteAppliance(appliance.id);
                  Get.back();
                  Get.back();
                  Get.back();
                },
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text;

              if (name.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a device name',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
                return;
              }

              final updatedAppliance = appliance.copyWith(name: name);
              controller.updateAppliance(updatedAppliance);
              Get.back();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'lightbulb':
        return Icons.lightbulb;
      case 'tv':
        return Icons.tv;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'kitchen':
        return Icons.kitchen;
      case 'local_laundry_service':
        return Icons.local_laundry_service;
      case 'air':
        return Icons.air;
      default:
        return Icons.devices;
    }
  }
}
