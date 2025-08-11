import 'package:flutter/material.dart';
import 'package:mirrorsbeautylounge/app_colors.dart';
import 'package:mirrorsbeautylounge/booking_history_screen.dart';

class ServiceBookingScreen extends StatefulWidget {
  const ServiceBookingScreen({super.key});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  final List<Map<String, dynamic>> services = [
    {'name': 'Haircut', 'price': 'PKR 500', 'duration': '30 mins', 'added': false},
    {'name': 'Facial', 'price': 'PKR 800', 'duration': '45 mins', 'added': false},
    {'name': 'Beard Trim', 'price': 'PKR 300', 'duration': '20 mins', 'added': false},
    {'name': 'Hair Coloring', 'price': 'PKR 1200', 'duration': '60 mins', 'added': false},
  ];

  DateTime selectedDate = DateTime.now();
  String? selectedTime;
  String? selectedService;
  final customerName = "John Doe";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          if (customerName.isNotEmpty) _buildCustomerInfo(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Appointment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Service:", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                Text("Haircut",style: TextStyle(color: Colors.white),),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date:", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                Text("August 8, 2025",style: TextStyle(color: Colors.white)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Time:", style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                                Text("4:30 PM",style: TextStyle(color: Colors.white)),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                  _buildSectionTitle("Available Services"),
                  SizedBox(height: 6),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) => _buildServiceCard(services[index]),
                  ),
                  const SizedBox(height: 24),
                  if (selectedService != null) ...[
                    _buildSectionTitle("Select Date"),
                    const SizedBox(height: 16),
                    _buildDateSelector(),
                    const SizedBox(height: 24),
                    _buildSectionTitle("Available Time Slots"),
                    const SizedBox(height: 16),
                    _buildTimeSlotsGrid(),
                    const SizedBox(height: 40),
                  ]
                ],
              ),
            ),
          ),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: const Color(0x1A000000), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textColor,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.access_time, size: 28, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          Text(
            'Book Your Service',
            style: TextStyle(color: AppColors.textColor, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.person, size: 20, color: AppColors.primaryColor),
          const SizedBox(width: 10),
          Text('Customer: $customerName', style: TextStyle(color: AppColors.textColor, fontSize: 16)),
          Spacer(),
          TextButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>BookingHistoryScreen()));
          }, child: Text("View History",style: TextStyle(color: AppColors.primaryColor,fontSize: 16),))
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, style: TextStyle(color: AppColors.primaryColor, fontSize: 20, fontWeight: FontWeight.bold));

  Widget _buildServiceCard(Map<String, dynamic> service) {
    final isSelected = service['name'] == selectedService;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0x0A000000), blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.cut, size: 24, color: AppColors.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(service['name'], style: TextStyle(color: AppColors.textColor, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(service['price'], style: TextStyle(color: AppColors.primaryColor, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(service['duration'], style: TextStyle(color: AppColors.greyColor, fontSize: 14)),
                const Spacer(),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() {
                      selectedService = isSelected ? null : service['name'];
                      selectedTime = null;
                    }),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? AppColors.primaryColor : Colors.white,
                      foregroundColor: isSelected ? Colors.white : AppColors.primaryColor,
                      minimumSize: const Size(double.infinity, 35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.primaryColor),
                      ),
                    ),
                    child: Text(isSelected ? 'SELECTED' : 'SELECT'),
                  ),
                ),
              ],
            ),
          ),
          if (service['added'])
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(20)),
                child: const Icon(Icons.check, size: 16, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    return Row(
      children: [
        _buildDateOption(today, "Today"),
        const SizedBox(width: 16),
        _buildDateOption(tomorrow, "Tomorrow"),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.calendar_today, size: 20),
          color: AppColors.primaryColor,
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: today,
              lastDate: today.add(const Duration(days: 30)),
            );
            if (picked != null && picked != selectedDate) {
              setState(() {
                selectedDate = picked;
                selectedTime = null;
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildDateOption(DateTime date, String label) {
    final isSelected = selectedDate.day == date.day;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => setState(() {
          selectedDate = date;
          selectedTime = null;
        }),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? AppColors.primaryColor : Colors.white,
          foregroundColor: isSelected ? Colors.white : AppColors.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.primaryColor),
          ),
        ),
        child: Column(
          children: [
            Text('${date.day}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotsGrid() {
    final timeSlots = [
      "9:00 AM", "10:00 AM", "11:00 AM", "12:00 PM",
      "1:00 PM", "2:00 PM", "3:00 PM", "4:00 PM",
      "5:00 PM", "6:00 PM", "7:00 PM", "8:00 PM"
    ];
    final unavailableSlots = ["10:00 AM", "3:00 PM", "6:00 PM"];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.8,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        final isUnavailable = unavailableSlots.contains(slot);
        final isSelected = selectedTime == slot;

        return ElevatedButton(
          onPressed: isUnavailable ? null : () => setState(() => selectedTime = isSelected ? null : slot),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? AppColors.primaryColor : (isUnavailable ? const Color(0xFFEEEEEE) : Colors.white),
            foregroundColor: isSelected ? Colors.white : (isUnavailable ? AppColors.greyColor : AppColors.textColor),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: isUnavailable ? const Color(0xFFEEEEEE) : AppColors.primaryColor),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(slot, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              if (isUnavailable) const Text("Unavailable", style: TextStyle(fontSize: 9)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton() {
    final isEnabled = selectedService != null && selectedTime != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: const Color(0x1A000000), blurRadius: 6, offset: Offset(0, -2))],
      ),
      child: Column(
        children: [
          if (isEnabled)
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Text("$selectedService at $selectedTime", style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ElevatedButton(
            onPressed: isEnabled ? () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Added $selectedService to cart!', style: const TextStyle(color: Colors.white)),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
              setState(() {
                for (var service in services) {
                  if (service['name'] == selectedService) {
                    service['added'] = true;
                  }
                }
                selectedService = null;
                selectedTime = null;
              });
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('ADD TO CART', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
