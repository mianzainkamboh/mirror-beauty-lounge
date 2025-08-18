import 'package:flutter/material.dart';
import 'constants.dart';

class CountryCode {
  final String name;
  final String code;
  final String flag;

  CountryCode({required this.name, required this.code, required this.flag});
}

class PhoneInputField extends StatefulWidget {
  final String countryCode;
  final Function(String) onChanged;

  const PhoneInputField({
    super.key,
    required this.countryCode,
    required this.onChanged,
  });

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  final TextEditingController _phoneController = TextEditingController();
  late CountryCode _selectedCountry;
  
  final List<CountryCode> _countries = [
    CountryCode(name: 'Afghanistan', code: '+93', flag: '🇦🇫'),
    CountryCode(name: 'Albania', code: '+355', flag: '🇦🇱'),
    CountryCode(name: 'Algeria', code: '+213', flag: '🇩🇿'),
    CountryCode(name: 'Andorra', code: '+376', flag: '🇦🇩'),
    CountryCode(name: 'Angola', code: '+244', flag: '🇦🇴'),
    CountryCode(name: 'Argentina', code: '+54', flag: '🇦🇷'),
    CountryCode(name: 'Armenia', code: '+374', flag: '🇦🇲'),
    CountryCode(name: 'Australia', code: '+61', flag: '🇦🇺'),
    CountryCode(name: 'Austria', code: '+43', flag: '🇦🇹'),
    CountryCode(name: 'Azerbaijan', code: '+994', flag: '🇦🇿'),
    CountryCode(name: 'Bahrain', code: '+973', flag: '🇧🇭'),
    CountryCode(name: 'Bangladesh', code: '+880', flag: '🇧🇩'),
    CountryCode(name: 'Belarus', code: '+375', flag: '🇧🇾'),
    CountryCode(name: 'Belgium', code: '+32', flag: '🇧🇪'),
    CountryCode(name: 'Belize', code: '+501', flag: '🇧🇿'),
    CountryCode(name: 'Benin', code: '+229', flag: '🇧🇯'),
    CountryCode(name: 'Bhutan', code: '+975', flag: '🇧🇹'),
    CountryCode(name: 'Bolivia', code: '+591', flag: '🇧🇴'),
    CountryCode(name: 'Bosnia and Herzegovina', code: '+387', flag: '🇧🇦'),
    CountryCode(name: 'Botswana', code: '+267', flag: '🇧🇼'),
    CountryCode(name: 'Brazil', code: '+55', flag: '🇧🇷'),
    CountryCode(name: 'Brunei', code: '+673', flag: '🇧🇳'),
    CountryCode(name: 'Bulgaria', code: '+359', flag: '🇧🇬'),
    CountryCode(name: 'Burkina Faso', code: '+226', flag: '🇧🇫'),
    CountryCode(name: 'Burundi', code: '+257', flag: '🇧🇮'),
    CountryCode(name: 'Cambodia', code: '+855', flag: '🇰🇭'),
    CountryCode(name: 'Cameroon', code: '+237', flag: '🇨🇲'),
    CountryCode(name: 'Canada', code: '+1', flag: '🇨🇦'),
    CountryCode(name: 'Cape Verde', code: '+238', flag: '🇨🇻'),
    CountryCode(name: 'Central African Republic', code: '+236', flag: '🇨🇫'),
    CountryCode(name: 'Chad', code: '+235', flag: '🇹🇩'),
    CountryCode(name: 'Chile', code: '+56', flag: '🇨🇱'),
    CountryCode(name: 'China', code: '+86', flag: '🇨🇳'),
    CountryCode(name: 'Colombia', code: '+57', flag: '🇨🇴'),
    CountryCode(name: 'Comoros', code: '+269', flag: '🇰🇲'),
    CountryCode(name: 'Congo', code: '+242', flag: '🇨🇬'),
    CountryCode(name: 'Costa Rica', code: '+506', flag: '🇨🇷'),
    CountryCode(name: 'Croatia', code: '+385', flag: '🇭🇷'),
    CountryCode(name: 'Cuba', code: '+53', flag: '🇨🇺'),
    CountryCode(name: 'Cyprus', code: '+357', flag: '🇨🇾'),
    CountryCode(name: 'Czech Republic', code: '+420', flag: '🇨🇿'),
    CountryCode(name: 'Denmark', code: '+45', flag: '🇩🇰'),
    CountryCode(name: 'Djibouti', code: '+253', flag: '🇩🇯'),
    CountryCode(name: 'Dominican Republic', code: '+1', flag: '🇩🇴'),
    CountryCode(name: 'Ecuador', code: '+593', flag: '🇪🇨'),
    CountryCode(name: 'Egypt', code: '+20', flag: '🇪🇬'),
    CountryCode(name: 'El Salvador', code: '+503', flag: '🇸🇻'),
    CountryCode(name: 'Equatorial Guinea', code: '+240', flag: '🇬🇶'),
    CountryCode(name: 'Eritrea', code: '+291', flag: '🇪🇷'),
    CountryCode(name: 'Estonia', code: '+372', flag: '🇪🇪'),
    CountryCode(name: 'Ethiopia', code: '+251', flag: '🇪🇹'),
    CountryCode(name: 'Fiji', code: '+679', flag: '🇫🇯'),
    CountryCode(name: 'Finland', code: '+358', flag: '🇫🇮'),
    CountryCode(name: 'France', code: '+33', flag: '🇫🇷'),
    CountryCode(name: 'Gabon', code: '+241', flag: '🇬🇦'),
    CountryCode(name: 'Gambia', code: '+220', flag: '🇬🇲'),
    CountryCode(name: 'Georgia', code: '+995', flag: '🇬🇪'),
    CountryCode(name: 'Germany', code: '+49', flag: '🇩🇪'),
    CountryCode(name: 'Ghana', code: '+233', flag: '🇬🇭'),
    CountryCode(name: 'Greece', code: '+30', flag: '🇬🇷'),
    CountryCode(name: 'Guatemala', code: '+502', flag: '🇬🇹'),
    CountryCode(name: 'Guinea', code: '+224', flag: '🇬🇳'),
    CountryCode(name: 'Guinea-Bissau', code: '+245', flag: '🇬🇼'),
    CountryCode(name: 'Guyana', code: '+592', flag: '🇬🇾'),
    CountryCode(name: 'Haiti', code: '+509', flag: '🇭🇹'),
    CountryCode(name: 'Honduras', code: '+504', flag: '🇭🇳'),
    CountryCode(name: 'Hungary', code: '+36', flag: '🇭🇺'),
    CountryCode(name: 'Iceland', code: '+354', flag: '🇮🇸'),
    CountryCode(name: 'India', code: '+91', flag: '🇮🇳'),
    CountryCode(name: 'Indonesia', code: '+62', flag: '🇮🇩'),
    CountryCode(name: 'Iran', code: '+98', flag: '🇮🇷'),
    CountryCode(name: 'Iraq', code: '+964', flag: '🇮🇶'),
    CountryCode(name: 'Ireland', code: '+353', flag: '🇮🇪'),
    CountryCode(name: 'Israel', code: '+972', flag: '🇮🇱'),
    CountryCode(name: 'Italy', code: '+39', flag: '🇮🇹'),
    CountryCode(name: 'Jamaica', code: '+1', flag: '🇯🇲'),
    CountryCode(name: 'Japan', code: '+81', flag: '🇯🇵'),
    CountryCode(name: 'Jordan', code: '+962', flag: '🇯🇴'),
    CountryCode(name: 'Kazakhstan', code: '+7', flag: '🇰🇿'),
    CountryCode(name: 'Kenya', code: '+254', flag: '🇰🇪'),
    CountryCode(name: 'Kuwait', code: '+965', flag: '🇰🇼'),
    CountryCode(name: 'Kyrgyzstan', code: '+996', flag: '🇰🇬'),
    CountryCode(name: 'Laos', code: '+856', flag: '🇱🇦'),
    CountryCode(name: 'Latvia', code: '+371', flag: '🇱🇻'),
    CountryCode(name: 'Lebanon', code: '+961', flag: '🇱🇧'),
    CountryCode(name: 'Lesotho', code: '+266', flag: '🇱🇸'),
    CountryCode(name: 'Liberia', code: '+231', flag: '🇱🇷'),
    CountryCode(name: 'Libya', code: '+218', flag: '🇱🇾'),
    CountryCode(name: 'Lithuania', code: '+370', flag: '🇱🇹'),
    CountryCode(name: 'Luxembourg', code: '+352', flag: '🇱🇺'),
    CountryCode(name: 'Madagascar', code: '+261', flag: '🇲🇬'),
    CountryCode(name: 'Malawi', code: '+265', flag: '🇲🇼'),
    CountryCode(name: 'Malaysia', code: '+60', flag: '🇲🇾'),
    CountryCode(name: 'Maldives', code: '+960', flag: '🇲🇻'),
    CountryCode(name: 'Mali', code: '+223', flag: '🇲🇱'),
    CountryCode(name: 'Malta', code: '+356', flag: '🇲🇹'),
    CountryCode(name: 'Mauritania', code: '+222', flag: '🇲🇷'),
    CountryCode(name: 'Mauritius', code: '+230', flag: '🇲🇺'),
    CountryCode(name: 'Mexico', code: '+52', flag: '🇲🇽'),
    CountryCode(name: 'Moldova', code: '+373', flag: '🇲🇩'),
    CountryCode(name: 'Monaco', code: '+377', flag: '🇲🇨'),
    CountryCode(name: 'Mongolia', code: '+976', flag: '🇲🇳'),
    CountryCode(name: 'Montenegro', code: '+382', flag: '🇲🇪'),
    CountryCode(name: 'Morocco', code: '+212', flag: '🇲🇦'),
    CountryCode(name: 'Mozambique', code: '+258', flag: '🇲🇿'),
    CountryCode(name: 'Myanmar', code: '+95', flag: '🇲🇲'),
    CountryCode(name: 'Namibia', code: '+264', flag: '🇳🇦'),
    CountryCode(name: 'Nepal', code: '+977', flag: '🇳🇵'),
    CountryCode(name: 'Netherlands', code: '+31', flag: '🇳🇱'),
    CountryCode(name: 'New Zealand', code: '+64', flag: '🇳🇿'),
    CountryCode(name: 'Nicaragua', code: '+505', flag: '🇳🇮'),
    CountryCode(name: 'Niger', code: '+227', flag: '🇳🇪'),
    CountryCode(name: 'Nigeria', code: '+234', flag: '🇳🇬'),
    CountryCode(name: 'North Korea', code: '+850', flag: '🇰🇵'),
    CountryCode(name: 'Norway', code: '+47', flag: '🇳🇴'),
    CountryCode(name: 'Oman', code: '+968', flag: '🇴🇲'),
    CountryCode(name: 'Pakistan', code: '+92', flag: '🇵🇰'),
    CountryCode(name: 'Panama', code: '+507', flag: '🇵🇦'),
    CountryCode(name: 'Papua New Guinea', code: '+675', flag: '🇵🇬'),
    CountryCode(name: 'Paraguay', code: '+595', flag: '🇵🇾'),
    CountryCode(name: 'Peru', code: '+51', flag: '🇵🇪'),
    CountryCode(name: 'Philippines', code: '+63', flag: '🇵🇭'),
    CountryCode(name: 'Poland', code: '+48', flag: '🇵🇱'),
    CountryCode(name: 'Portugal', code: '+351', flag: '🇵🇹'),
    CountryCode(name: 'Qatar', code: '+974', flag: '🇶🇦'),
    CountryCode(name: 'Romania', code: '+40', flag: '🇷🇴'),
    CountryCode(name: 'Russia', code: '+7', flag: '🇷🇺'),
    CountryCode(name: 'Rwanda', code: '+250', flag: '🇷🇼'),
    CountryCode(name: 'Saudi Arabia', code: '+966', flag: '🇸🇦'),
    CountryCode(name: 'Senegal', code: '+221', flag: '🇸🇳'),
    CountryCode(name: 'Serbia', code: '+381', flag: '🇷🇸'),
    CountryCode(name: 'Singapore', code: '+65', flag: '🇸🇬'),
    CountryCode(name: 'Slovakia', code: '+421', flag: '🇸🇰'),
    CountryCode(name: 'Slovenia', code: '+386', flag: '🇸🇮'),
    CountryCode(name: 'Somalia', code: '+252', flag: '🇸🇴'),
    CountryCode(name: 'South Africa', code: '+27', flag: '🇿🇦'),
    CountryCode(name: 'South Korea', code: '+82', flag: '🇰🇷'),
    CountryCode(name: 'Spain', code: '+34', flag: '🇪🇸'),
    CountryCode(name: 'Sri Lanka', code: '+94', flag: '🇱🇰'),
    CountryCode(name: 'Sudan', code: '+249', flag: '🇸🇩'),
    CountryCode(name: 'Sweden', code: '+46', flag: '🇸🇪'),
    CountryCode(name: 'Switzerland', code: '+41', flag: '🇨🇭'),
    CountryCode(name: 'Syria', code: '+963', flag: '🇸🇾'),
    CountryCode(name: 'Taiwan', code: '+886', flag: '🇹🇼'),
    CountryCode(name: 'Tajikistan', code: '+992', flag: '🇹🇯'),
    CountryCode(name: 'Tanzania', code: '+255', flag: '🇹🇿'),
    CountryCode(name: 'Thailand', code: '+66', flag: '🇹🇭'),
    CountryCode(name: 'Togo', code: '+228', flag: '🇹🇬'),
    CountryCode(name: 'Tunisia', code: '+216', flag: '🇹🇳'),
    CountryCode(name: 'Turkey', code: '+90', flag: '🇹🇷'),
    CountryCode(name: 'Turkmenistan', code: '+993', flag: '🇹🇲'),
    CountryCode(name: 'Uganda', code: '+256', flag: '🇺🇬'),
    CountryCode(name: 'Ukraine', code: '+380', flag: '🇺🇦'),
    CountryCode(name: 'United Arab Emirates', code: '+971', flag: '🇦🇪'),
    CountryCode(name: 'United Kingdom', code: '+44', flag: '🇬🇧'),
    CountryCode(name: 'United States', code: '+1', flag: '🇺🇸'),
    CountryCode(name: 'Uruguay', code: '+598', flag: '🇺🇾'),
    CountryCode(name: 'Uzbekistan', code: '+998', flag: '🇺🇿'),
    CountryCode(name: 'Venezuela', code: '+58', flag: '🇻🇪'),
    CountryCode(name: 'Vietnam', code: '+84', flag: '🇻🇳'),
    CountryCode(name: 'Yemen', code: '+967', flag: '🇾🇪'),
    CountryCode(name: 'Zambia', code: '+260', flag: '🇿🇲'),
    CountryCode(name: 'Zimbabwe', code: '+263', flag: '🇿🇼'),
  ];

  @override
  void initState() {
    super.initState();
    // Default to UK
    _selectedCountry = _countries.firstWhere(
      (country) => country.code == '+44',
      orElse: () => _countries.first,
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phone Number',
          style: TextStyle(
            color: AppColors.greyColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // Country code dropdown section
              GestureDetector(
                onTap: _showCountryPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedCountry.flag,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedCountry.code,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ),
              // Phone number input
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter phone number',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  onChanged: (value) {
                    final fullNumber = '${_selectedCountry.code} $value';
                    widget.onChanged(fullNumber);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Select Country',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _countries.length,
                  itemBuilder: (context, index) {
                    final country = _countries[index];
                    return ListTile(
                      leading: Text(
                        country.flag,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(country.name),
                      trailing: Text(
                        country.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.greyColor,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedCountry = country;
                        });
                        Navigator.pop(context);
                        // Update the phone number with new country code
                        final phoneNumber = _phoneController.text;
                        if (phoneNumber.isNotEmpty) {
                          final fullNumber = '${_selectedCountry.code} $phoneNumber';
                          widget.onChanged(fullNumber);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}