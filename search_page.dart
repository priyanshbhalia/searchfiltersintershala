import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

class Internship {
  final String profile;
  final String city;
  final int duration;

  Internship({required this.profile, required this.city, required this.duration});

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      profile: json['profile'],
      city: json['city'],
      duration: json['duration'],
    );
  }
}

class ApiService {
  static const String url = 'https://internshala.com/flutter_hiring/search';

  Future<List<Internship>> fetchInternships() async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] != null) {
        List internships = jsonResponse['data'];
        return internships.map((internship) => Internship.fromJson(internship)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load internships');
    }
  }

  Future<List<Internship>> fetchInternshipsWithFilters(Map<String, dynamic> filters) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] != null) {
        List internships = jsonResponse['data'];
        List<Internship> internshipList = internships.map((internship) => Internship.fromJson(internship)).toList();

        if (filters['profile'] != null) {
          internshipList = internshipList.where((i) => i.profile == filters['profile']).toList();
        }
        if (filters['city'] != null) {
          internshipList = internshipList.where((i) => i.city == filters['city']).toList();
        }
        if (filters['duration'] != null) {
          internshipList = internshipList.where((i) => i.duration == filters['duration']).toList();
        }

        return internshipList;
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load internships');
    }
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Internship>> futureInternships;
  Map<String, dynamic> filters = {};

  @override
  void initState() {
    super.initState();
    futureInternships = ApiService().fetchInternships();
  }

  void applyFilters(Map<String, dynamic> newFilters) {
    setState(() {
      filters = newFilters;
      futureInternships = ApiService().fetchInternshipsWithFilters(filters);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: AppBar().preferredSize.height, // Set height to match AppBar
          child: SvgPicture.asset(
            
            'lib/assets/logo.svg',
            color: Colors.blue, // Path to your SVG file
            fit: BoxFit.contain, // Adjust the fit as necessary
          ),
        ),
      ),
      body: Row(
        children: [
          Flexible(
            flex: 2,
            child: FilterWidget(
              onApplyFilters: (newFilters) {
                applyFilters(newFilters);
              },
            ),
          ),
          Flexible(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<List<Internship>>(
                future: futureInternships,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No internships found'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Internship internship = snapshot.data![index];
                        return ListTile(
                          title: Text(internship.profile),
                          subtitle: Text('${internship.city} - ${internship.duration} months'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// class FilterWidget extends StatefulWidget {
//   final Function(Map<String, dynamic>) onApplyFilters;

//   FilterWidget({required this.onApplyFilters});

//   @override
//   _FilterWidgetState createState() => _FilterWidgetState();
// }

// class _FilterWidgetState extends State<FilterWidget> {
//   String? selectedProfile;
//   String? selectedCity;
//   int? selectedDuration;
//   bool asPerPreferences = false;
//   bool workFromHome = false;
//   bool partTime = false;
//   double minStipend = 0;

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.filter_list, color: Colors.blue),
//               SizedBox(width: 8),
//               Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           SizedBox(height: 10),
//           Row(
//             children: [
//               Checkbox(
//                 value: asPerPreferences,
//                 onChanged: (newValue) {
//                   setState(() {
//                     asPerPreferences = newValue!;
//                   });
//                 },
//               ),
//               Text('As per my '),
//               GestureDetector(
//                 onTap: () {
//                   // Handle preferences tap
//                 },
//                 child: Text(
//                   'preferences',
//                   style: TextStyle(color: Colors.blue),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10),
//           Text('Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//           DropdownButtonFormField<String>(
//             hint: Text('e.g. Marketing'),
//             value: selectedProfile,
//             onChanged: (newValue) {
//               setState(() {
//                 selectedProfile = newValue;
//               });
//             },
//             items: ['Developer', 'Designer', 'Marketing'].map((profile) {
//               return DropdownMenuItem(
//                 child: Text(profile),
//                 value: profile,
//               );
//             }).toList(),
//           ),
//           SizedBox(height: 10),
//           Text('Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//           DropdownButtonFormField<String>(
//             hint: Text('Select City'),
//             value: selectedCity,
//             onChanged: (newValue) {
//               setState(() {
//                 selectedCity = newValue;
//               });
//             },
//             items: ['Delhi', 'Mumbai', 'Bangalore'].map((city) {
//               return DropdownMenuItem(
//                 child: Text(city),
//                 value: city,
//               );
//             }).toList(),
//           ),
//           SizedBox(height: 10),
//           Row(
//             children: [
//               Checkbox(
//                 value: workFromHome,
//                 onChanged: (newValue) {
//                   setState(() {
//                     workFromHome = newValue!;
//                   });
//                 },
//               ),
//               Text('Include work from home also'),
//             ],
//           ),
//           Row(
//             children: [
//               Checkbox(
//                 value: partTime,
//                 onChanged: (newValue) {
//                   setState(() {
//                     partTime = newValue!;
//                   });
//                 },
//               ),
//               Text('Part-time'),
//             ],
//           ),
//           SizedBox(height: 10),
//           Text('Desired minimum monthly stipend (₹)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
//           Slider(
//             value: minStipend,
//             min: 0,
//             max: 10000,
//             divisions: 5,
//             label: minStipend.round().toString(),
//             onChanged: (newValue) {
//               setState(() {
//                 minStipend = newValue;
//               });
//             },
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('View more filters', style: TextStyle(color: Colors.blue)),
//               Text('Clear all', style: TextStyle(color: Colors.blue)),
//             ],
//           ),
//           SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               widget.onApplyFilters({
//                 'profile': selectedProfile,
//                 'city': selectedCity,
//                 'duration': selectedDuration,
//                 'workFromHome': workFromHome,
//                 'partTime': partTime,
//                 'minStipend': minStipend,
//               });
//             },
//             child: Text('Apply Filters'),
//           ),
//         ],
//       ),
//     );
//   }
// }

class FilterWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  FilterWidget({required this.onApplyFilters});

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  String? selectedProfile;
  String? selectedCity;
  int? selectedDuration;
  bool asPerPreferences = false;
  bool workFromHome = false;
  bool partTime = false;
  double minStipend = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            
            children: [
              Icon(Icons.filter_list, color: Colors.blue),
              SizedBox(width: 8),
              Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: asPerPreferences,
                onChanged: (newValue) {
                  setState(() {
                    asPerPreferences = newValue!;
                  });
                },
              ),
              Text('As per my '),
              GestureDetector(
                onTap: () {
                 
                },
                child: Text(
                  'preferences',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text('Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          DropdownButtonFormField<String>(
            hint: Text('e.g. Marketing'),
            value: selectedProfile,
            onChanged: (newValue) {
              setState(() {
                selectedProfile = newValue;
              });
            },
            items: ['Developer', 'Designer', 'Marketing'].map((profile) {
              return DropdownMenuItem(
                child: Text(profile),
                value: profile,
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          Text('Location', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          DropdownButtonFormField<String>(
            hint: Text('Select City'),
            value: selectedCity,
            onChanged: (newValue) {
              setState(() {
                selectedCity = newValue;
              });
            },
            items: ['Delhi', 'Mumbai', 'Bangalore'].map((city) {
              return DropdownMenuItem(
                child: Text(city),
                value: city,
              );
            }).toList(),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Checkbox(
                value: workFromHome,
                onChanged: (newValue) {
                  setState(() {
                    workFromHome = newValue!;
                  });
                },
              ),
              Text('Include WFH'),
            ],
          ),
          Row(
            children: [
              Checkbox(
                value: partTime,
                onChanged: (newValue) {
                  setState(() {
                    partTime = newValue!;
                  });
                },
              ),
              Text('Part-time'),
            ],
          ),
          SizedBox(height: 10),
          Text('Desired minimum monthly stipend (₹)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Slider(
            value: minStipend,
            min: 0,
            max: 10000,
            divisions: 5,
            label: minStipend.round().toString(),
            onChanged: (newValue) {
              setState(() {
                minStipend = newValue;
              });
            },
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('View more filters', style: TextStyle(color: Colors.blue)),
              Text('Clear all', style: TextStyle(color: Colors.blue)),
            ],
          ),
          SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                widget.onApplyFilters({
                  'profile': selectedProfile,
                  'city': selectedCity,
                  'duration': selectedDuration,
                  'workFromHome': workFromHome,
                  'partTime': partTime,
                  'minStipend': minStipend,
                });
              },
              child: Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}