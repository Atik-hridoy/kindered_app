// import 'package:get/get.dart';

// class LikeToDoController extends GetxController {
//   // Options per category
//   final Map<String, List<String>> options = {
//     'creativity': ['Painting','Writing','Photography','Crafting','Design','Drawing','Sculpting','Pottery','Digital Art','Knitting','Calligraphy','Woodworking','Other'],
//     'activities': ['Hiking','Cooking','Traveling','Gaming','Reading','Camping','Fishing','Cycling','Photography','Gardening','Other'],
//     'sportsFitness': ['Gym','Running','Yoga','Cycling','Swimming','Weight Training','Pilates','Martial Arts','Dance','Hiking','Other'],
//     'tvMovies': ['Action','Comedy','Drama','Sci-Fi','Documentary','Thriller','Romance','Horror','Anime','Fantasy','Other'],
//     'freeTime': ['Socializing','Meditation','Learning','Volunteering','Shopping','Reading','Gaming','Watching TV/Movies','Listening to Music','Other'],
//     'music': ['Pop','Rock','Hip Hop','Classical','Jazz','R&B','Electronic','Country','Reggae','Metal','Other'],
//     'wellnessLifestyle': ['Meditation','Healthy Eating','Fitness','Mindfulness','Self-care','Yoga','Veganism','Minimalism','Sustainable Living','Mental Health','Other'],
//     'booksContent': ['Fiction','Non-fiction','Biography','Science','History','Fantasy','Mystery','Self-help','Science Fiction','Poetry','Other'],
//   };

//   // Selected indices
//   final Map<String, RxSet<int>> selectedOptions = {
//     'creativity': <int>{}.obs,
//     'activities': <int>{}.obs,
//     'sportsFitness': <int>{}.obs,
//     'tvMovies': <int>{}.obs,
//     'freeTime': <int>{}.obs,
//     'music': <int>{}.obs,
//     'wellnessLifestyle': <int>{}.obs,
//     'booksContent': <int>{}.obs,
//   };

//   // Toggle selection
//   void toggleOption(String category, int index) {
//     if (selectedOptions[category]!.contains(index)) {
//       selectedOptions[category]!.remove(index);
//     } else {
//       selectedOptions[category]!.add(index);
//     }
//   }

//   // Check completion
//   bool get isCompleted => selectedOptions.values.every((s) => s.isNotEmpty);
// }
