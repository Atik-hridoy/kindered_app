import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../controller/habit_controller.dart';
import '../widget/progress_bar.dart';
import '../widget/button.dart';
import '../widget/custom_pill_checkbox.dart';

class LikeToDoView extends StatefulWidget {
  const LikeToDoView({Key? key}) : super(key: key);

  @override
  State<LikeToDoView> createState() => _LikeToDoViewState();
}

class _LikeToDoViewState extends State<LikeToDoView> {
  final ScrollController _scrollController = ScrollController();
  
  // State variables for selected options (using Set to store multiple selections)
  final Map<String, Set<int>> _selectedOptions = {
    'creativity': {},
    'activities': {},
    'sportsFitness': {},
    'tvMovies': {},
    'freeTime': {},
    'music': {},
    'wellnessLifestyle': {},
    'booksContent': {},
  };
  
  // Check if all questions have at least one selection
  bool get _isCompleted => 
      _selectedOptions.values.every((selections) => selections.isNotEmpty);

  // Categories and options
  final List<String> creativityOptions = [
    'Painting',
    'Writing',
    'Photography',
    'Crafting',
    'Design',
    'Drawing',
    'Sculpting',
    'Pottery',
    'Digital Art',
    'Knitting',
    'Calligraphy',
    'Woodworking',
    'Other'
  ];

  final List<String> activitiesOptions = [
    'Hiking',
    'Cooking',
    'Traveling',
    'Gaming',
    'Reading',
    'Camping',
    'Fishing',
    'Cycling',
    'Photography',
    'Gardening',
    'Other'
  ];

  final List<String> sportsFitnessOptions = [
    'Gym',
    'Running',
    'Yoga',
    'Cycling',
    'Swimming',
    'Weight Training',
    'Pilates',
    'Martial Arts',
    'Dance',
    'Hiking',
    'Other'
  ];

  final List<String> tvMoviesOptions = [
    'Action',
    'Comedy',
    'Drama',
    'Sci-Fi',
    'Documentary',
    'Thriller',
    'Romance',
    'Horror',
    'Anime',
    'Fantasy',
    'Other'
  ];

  final List<String> freeTimeOptions = [
    'Socializing',
    'Meditation',
    'Learning',
    'Volunteering',
    'Shopping',
    'Reading',
    'Gaming',
    'Watching TV/Movies',
    'Listening to Music',
    'Other'
  ];

  final List<String> musicOptions = [
    'Pop',
    'Rock',
    'Hip Hop',
    'Classical',
    'Jazz',
    'R&B',
    'Electronic',
    'Country',
    'Reggae',
    'Metal',
    'Other'
  ];

  final List<String> wellnessLifestyleOptions = [
    'Meditation',
    'Healthy Eating',
    'Fitness',
    'Mindfulness',
    'Self-care',
    'Yoga',
    'Veganism',
    'Minimalism',
    'Sustainable Living',
    'Mental Health',
    'Other'
  ];

  final List<String> booksContentOptions = [
    'Fiction',
    'Non-fiction',
    'Biography',
    'Science',
    'History',
    'Fantasy',
    'Mystery',
    'Self-help',
    'Science Fiction',
    'Poetry',
    'Other'
  ];


  void _onNextPressed() {
    if (_isCompleted) {
      Get.toNamed(AppRoutes.visualStoryView);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildOptions(List<String> options, Set<int> selectedIndices, Function(int, bool) onOptionChanged) {
    return Wrap(
      spacing: 10,
      runSpacing: 12,
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = selectedIndices.contains(index);
        
        return CustomPillCheckbox(
          text: option,
          isSelected: isSelected,
          onChanged: (_) => onOptionChanged(index, !isSelected),
          selectedOpacity: 0.8,
          textStyle: GoogleFonts.playfairDisplay(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionSection(String question, String sectionKey, List<String> options) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A59).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2E3A59).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          _buildOptions(options, _selectedOptions[sectionKey] ?? {}, (index, isSelected) {
            setState(() {
              if (isSelected) {
                _selectedOptions[sectionKey]!.add(index);
              } else {
                _selectedOptions[sectionKey]!.remove(index);
              }
            });
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 20.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFFD4A373)),
            onPressed: () => Get.back(),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(45.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomProgressBar(
                  value: 1.0,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      body: GetBuilder<HabitController>(
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 308,
                        child: Text(
                          'Tell us what you really like to do or interested in!',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 22.0, // Increased from 17.0
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Choose those things on which you mostly interested that will help you to match with people who love them too.",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 15.0, // Increased from 12.5
                          color: Colors.white70,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 15), // Increased from 20
                      
                      
                      _buildQuestionSection(
                        'Creativity',
                        'creativity',
                        creativityOptions,
                      ),
                      
                      _buildQuestionSection(
                        'Activities',
                        'activities',
                        activitiesOptions,
                      ),

                      _buildQuestionSection(
                        'Sports and Fitness',
                        'sportsFitness',
                        sportsFitnessOptions,
                      ),
                      
                      _buildQuestionSection(
                        'TV and Movies',
                        'tvMovies',
                        tvMoviesOptions,
                      ),
                      
                      _buildQuestionSection(
                        'Free Time',
                        'freeTime',
                        freeTimeOptions,
                      ),

                      _buildQuestionSection(
                        'Music',
                        'music',
                        musicOptions,
                      ),

                      _buildQuestionSection(
                        'Wellness and Lifestyle',
                        'wellnessLifestyle',
                        wellnessLifestyleOptions,
                      ),

                      _buildQuestionSection(
                        'Books and Content',
                        'booksContent',
                        booksContentOptions,
                      ),

                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 50.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: CustomGradientButton(
          text: 'Next',
          onPressed: _isCompleted ? _onNextPressed : null,
          width: double.infinity,
          height: 48,
          borderRadius: 12,
          gradientColors: const [Color(0xFFD4A373), Color(0xFFB56E29)],
          textStyle: GoogleFonts.playfairDisplay(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
