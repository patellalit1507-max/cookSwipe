// Generates assets/data/food_dataset.json (>= 1000 realistic Indian dishes).
//
//   dart run tool/generate_dataset.dart
//
// The same JSON is used as the bundled offline dataset and as the input
// for tool/seed_firestore.mjs. Image URLs are deterministic placeholders
// (picsum.photos seeded by dish id) — replace with real food photos via
// the in-app admin panel or by editing this file.

import 'dart:convert';
import 'dart:io';

const allIndia = 'All India';

final List<Map<String, dynamic>> items = [];
final Set<String> usedIds = <String>{};

// Deterministic pseudo-random from a string, for stable times/popularity.
int hashOf(String s) {
  var h = 0;
  for (final c in s.codeUnits) {
    h = (h * 31 + c) & 0x7fffffff;
  }
  return h;
}

String slug(String s) => s
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
    .replaceAll(RegExp(r'^-+|-+$'), '');

void add(
  String name,
  String category, {
  String region = allIndia,
  bool veg = true,
  int? time,
  String? diff,
  int? pop,
}) {
  final id = '${slug(name)}_$category';
  if (!usedIds.add(id)) return; // skip duplicates silently
  final h = hashOf(id);
  final prepTime = time ?? (15 + (h % 7) * 5); // 15..45
  final difficulty =
      diff ?? (prepTime <= 20 ? 'easy' : (prepTime <= 40 ? 'medium' : 'hard'));
  items.add({
    'id': id,
    'name': name,
    'category': category,
    'imageUrl': 'https://picsum.photos/seed/$id/800/600',
    'region': region,
    'isVeg': veg,
    'prepTime': prepTime,
    'difficulty': difficulty,
    'popularityScore': pop ?? (40 + h % 31),
  });
}

/// Adds the same dish to both lunch and dinner (very common in Indian homes).
void addMeal(
  String name, {
  String region = allIndia,
  bool veg = true,
  int? time,
  String? diff,
  int? pop,
  List<String> meals = const ['lunch', 'dinner'],
}) {
  for (final m in meals) {
    add(name, m, region: region, veg: veg, time: time, diff: diff, pop: pop);
  }
}

void main() {
  // ============================ BREAKFAST =================================

  const dosas = [
    'Plain Dosa', 'Masala Dosa', 'Rava Dosa', 'Onion Dosa', 'Set Dosa',
    'Neer Dosa', 'Mysore Masala Dosa', 'Cheese Dosa', 'Paneer Dosa',
    'Podi Dosa', 'Ghee Roast Dosa', 'Butter Dosa', 'Oats Dosa', 'Ragi Dosa',
    'Pesarattu', 'Adai Dosa', 'Wheat Dosa', 'Jowar Dosa',
  ];
  for (final d in dosas) {
    add(d, 'breakfast',
        region: d == 'Pesarattu'
            ? 'Andhra Pradesh'
            : (d == 'Neer Dosa' ? 'Karnataka' : 'Karnataka'),
        time: 20,
        pop: d == 'Masala Dosa' ? 95 : null);
  }

  const idlis = [
    'Idli', 'Rava Idli', 'Button Idli', 'Thatte Idli', 'Podi Idli',
    'Fried Idli', 'Stuffed Idli', 'Oats Idli', 'Ragi Idli', 'Kanchipuram Idli',
  ];
  for (final d in idlis) {
    add(d, 'breakfast',
        region: d == 'Thatte Idli'
            ? 'Karnataka'
            : (d == 'Kanchipuram Idli' ? 'Tamil Nadu' : 'Tamil Nadu'),
        time: 20,
        pop: d == 'Idli' ? 92 : null);
  }

  const parathaFillings = [
    'Aloo', 'Gobi', 'Paneer', 'Methi', 'Mooli', 'Onion', 'Mixed Veg',
    'Palak', 'Cheese', 'Dal', 'Sattu', 'Beetroot', 'Carrot', 'Mint',
    'Ajwain', 'Besan',
  ];
  for (final f in parathaFillings) {
    final region = f == 'Sattu' ? 'Bihar' : 'Punjab';
    add('$f Paratha', 'breakfast',
        region: region, time: 25, pop: f == 'Aloo' ? 90 : null);
    // Parathas are an extremely common light dinner too.
    add('$f Paratha', 'dinner', region: region, time: 25);
  }
  add('Egg Paratha', 'breakfast', region: 'Punjab', veg: false, time: 25);
  add('Keema Paratha', 'breakfast', region: 'Punjab', veg: false, time: 35);

  const cheelas = [
    'Besan Cheela', 'Moong Dal Cheela', 'Oats Cheela', 'Ragi Cheela',
    'Mixed Dal Cheela', 'Suji Cheela',
  ];
  for (final d in cheelas) {
    add(d, 'breakfast', time: 15);
  }

  const upmas = [
    'Rava Upma', 'Vermicelli Upma', 'Oats Upma', 'Bread Upma',
    'Quinoa Upma', 'Tomato Upma', 'Masala Upma', 'Corn Upma',
  ];
  for (final d in upmas) {
    add(d, 'breakfast', region: 'Tamil Nadu', time: 15);
  }

  const pohas = [
    'Kanda Poha', 'Batata Poha', 'Indori Poha', 'Dadpe Pohe',
    'Lemon Poha', 'Curd Poha',
  ];
  for (final d in pohas) {
    add(d, 'breakfast',
        region: d == 'Indori Poha' ? 'Madhya Pradesh' : 'Maharashtra',
        time: 15,
        pop: d == 'Kanda Poha' ? 85 : null);
  }

  // (name, region, veg, time)
  const breakfastSingles = [
    ['Upma Pesarattu', 'Andhra Pradesh', true, 25],
    ['Ven Pongal', 'Tamil Nadu', true, 30],
    ['Sweet Pongal', 'Tamil Nadu', true, 30],
    ['Uttapam', 'Tamil Nadu', true, 20],
    ['Onion Tomato Uttapam', 'Tamil Nadu', true, 20],
    ['Mini Uttapam', 'Tamil Nadu', true, 20],
    ['Medu Vada with Sambar', 'Tamil Nadu', true, 30],
    ['Appam with Stew', 'Kerala', true, 35],
    ['Idiyappam', 'Kerala', true, 30],
    ['Puttu with Kadala Curry', 'Kerala', true, 30],
    ['Kerala Egg Roast with Appam', 'Kerala', false, 35],
    ['Pathiri', 'Kerala', true, 30],
    ['Bisi Bele Bath', 'Karnataka', true, 40],
    ['Khara Bath', 'Karnataka', true, 20],
    ['Kesari Bath', 'Karnataka', true, 20],
    ['Chow Chow Bath', 'Karnataka', true, 25],
    ['Akki Roti', 'Karnataka', true, 25],
    ['Ragi Mudde', 'Karnataka', true, 20],
    ['Davanagere Benne Dosa', 'Karnataka', true, 25],
    ['Mangalore Buns', 'Karnataka', true, 30],
    ['Misal Pav', 'Maharashtra', true, 35],
    ['Sabudana Khichdi', 'Maharashtra', true, 25],
    ['Sabudana Vada', 'Maharashtra', true, 30],
    ['Thalipeeth', 'Maharashtra', true, 25],
    ['Upvas Bhagar', 'Maharashtra', true, 20],
    ['Thepla', 'Gujarat', true, 25],
    ['Methi Thepla', 'Gujarat', true, 25],
    ['Khaman Dhokla', 'Gujarat', true, 30],
    ['Khandvi', 'Gujarat', true, 30],
    ['Handvo', 'Gujarat', true, 45],
    ['Fafda Jalebi', 'Gujarat', true, 30],
    ['Sev Khamani', 'Gujarat', true, 25],
    ['Chole Bhature', 'Punjab', true, 45],
    ['Amritsari Kulcha', 'Punjab', true, 40],
    ['Stuffed Kulcha with Chole', 'Punjab', true, 40],
    ['Poori Bhaji', allIndia, true, 30],
    ['Bedmi Puri with Aloo Sabzi', 'Delhi', true, 40],
    ['Nagori Halwa', 'Delhi', true, 40],
    ['Daulat ki Chaat', 'Delhi', true, 20],
    ['Pyaaz Kachori', 'Rajasthan', true, 40],
    ['Mirchi Vada', 'Rajasthan', true, 30],
    ['Dal Pakwan', 'Gujarat', true, 35],
    ['Luchi with Aloo Dum', 'West Bengal', true, 35],
    ['Radhaballavi', 'West Bengal', true, 40],
    ['Koraishutir Kachori', 'West Bengal', true, 40],
    ['Ghugni', 'West Bengal', true, 30],
    ['Litti Chokha', 'Bihar', true, 45],
    ['Chura Dahi', 'Bihar', true, 10],
    ['Aloo Puri', 'Uttar Pradesh', true, 30],
    ['Tehri', 'Uttar Pradesh', true, 35],
    ['Jalebi with Doodh', 'Uttar Pradesh', true, 30],
    ['Cornflakes with Milk', allIndia, true, 5],
    ['Oats Porridge', allIndia, true, 10],
    ['Masala Oats', allIndia, true, 12],
    ['Fruit Bowl with Curd', allIndia, true, 10],
    ['Vegetable Daliya', allIndia, true, 20],
    ['Sprouts Salad', allIndia, true, 10],
    ['Peanut Butter Toast', allIndia, true, 5],
    ['Banana Pancakes', allIndia, true, 15],
    ['Suji Toast', allIndia, true, 15],
    ['Bread Pakoda', allIndia, true, 20],
    ['Vegetable Sandwich Breakfast', allIndia, true, 10],
    ['Aloo Sandwich', allIndia, true, 15],
    ['Idli Upma', 'Tamil Nadu', true, 15],
    ['Semiya Kichadi', 'Tamil Nadu', true, 20],
    ['Adai Avial', 'Tamil Nadu', true, 35],
    ['Kuzhi Paniyaram', 'Tamil Nadu', true, 25],
    ['Punugulu', 'Andhra Pradesh', true, 25],
    ['Attu', 'Andhra Pradesh', true, 20],
    ['Gunta Ponganalu', 'Andhra Pradesh', true, 25],
    ['Sarva Pindi', 'Telangana', true, 30],
    ['Bread Omelette', allIndia, false, 10],
    ['Masala Omelette', allIndia, false, 10],
    ['Egg Bhurji with Pav', allIndia, false, 15],
    ['Boiled Eggs with Toast', allIndia, false, 12],
    ['Cheese Omelette', allIndia, false, 12],
    ['French Toast', allIndia, false, 15],
    ['Egg Dosa', 'Tamil Nadu', false, 20],
    ['Anda Paratha Roll', 'Delhi', false, 20],
    ['Akuri on Toast', 'Maharashtra', false, 15],
    ['Half Fry Eggs with Pav', allIndia, false, 10],
  ];
  for (final row in breakfastSingles) {
    add(row[0] as String, 'breakfast',
        region: row[1] as String, veg: row[2] as bool, time: row[3] as int);
  }

  // ============================== SNACKS ==================================

  const pakodas = [
    'Onion', 'Aloo', 'Palak', 'Gobi', 'Paneer', 'Mirchi', 'Bread',
    'Moong Dal', 'Cabbage', 'Corn', 'Methi', 'Mix Veg',
  ];
  for (final p in pakodas) {
    add('$p Pakoda', 'snacks', time: 20, pop: p == 'Onion' ? 88 : null);
  }
  add('Chicken Pakoda', 'snacks', veg: false, time: 30);
  add('Egg Pakoda', 'snacks', veg: false, time: 20);

  const chaats = [
    ['Samosa', allIndia, 85],
    ['Samosa Chaat', 'Delhi', 75],
    ['Aloo Tikki Chaat', 'Delhi', 80],
    ['Papdi Chaat', 'Delhi', 75],
    ['Dahi Bhalla', 'Delhi', 78],
    ['Raj Kachori', 'Rajasthan', 70],
    ['Bhel Puri', 'Maharashtra', 82],
    ['Sev Puri', 'Maharashtra', 75],
    ['Pani Puri', 'Maharashtra', 90],
    ['Dahi Puri', 'Maharashtra', 74],
    ['Ragda Pattice', 'Maharashtra', 70],
    ['Masala Puri', 'Karnataka', 72],
    ['Churumuri', 'Karnataka', 65],
    ['Jhal Muri', 'West Bengal', 70],
    ['Ghugni Chaat', 'West Bengal', 60],
    ['Kuzhi Paniyaram Chaat', 'Tamil Nadu', 55],
    ['Corn Chaat', allIndia, 60],
    ['Fruit Chaat', allIndia, 58],
  ];
  for (final row in chaats) {
    add(row[0] as String, 'snacks',
        region: row[1] as String, time: 20, pop: row[2] as int);
  }

  const vadas = [
    ['Medu Vada', 'Tamil Nadu'],
    ['Masala Vada', 'Tamil Nadu'],
    ['Maddur Vada', 'Karnataka'],
    ['Aloo Bonda', 'Karnataka'],
    ['Batata Vada', 'Maharashtra'],
    ['Vada Pav', 'Maharashtra'],
    ['Dahi Vada', allIndia],
    ['Rava Vada', 'Karnataka'],
    ['Goli Baje', 'Karnataka'],
    ['Mysore Bonda', 'Karnataka'],
  ];
  for (final row in vadas) {
    add(row[0], 'snacks',
        region: row[1], time: 25, pop: row[0] == 'Vada Pav' ? 88 : null);
  }

  const sandwiches = [
    'Veg Sandwich', 'Grilled Cheese Sandwich', 'Bombay Masala Toast',
    'Paneer Tikka Sandwich', 'Corn Cheese Sandwich', 'Cucumber Sandwich',
    'Club Sandwich', 'Chutney Sandwich', 'Veg Cheese Grilled Sandwich',
    'Masala Bun', 'Garlic Bread', 'Cheese Chilli Toast',
  ];
  for (final s in sandwiches) {
    add(s, 'snacks',
        region: s.contains('Bombay') ? 'Maharashtra' : allIndia, time: 15);
  }
  add('Chicken Sandwich', 'snacks', veg: false, time: 20);
  add('Egg Mayo Sandwich', 'snacks', veg: false, time: 15);

  const cutlets = [
    'Veg Cutlet', 'Aloo Tikki', 'Paneer Cutlet', 'Beetroot Cutlet',
    'Poha Cutlet', 'Sabudana Tikki', 'Corn Tikki', 'Hara Bhara Kabab',
    'Dahi Ke Kabab', 'Rajma Tikki',
  ];
  for (final c in cutlets) {
    add(c, 'snacks', time: 25);
  }
  add('Chicken Cutlet', 'snacks', veg: false, time: 30);
  add('Fish Cutlet', 'snacks', region: 'West Bengal', veg: false, time: 30);

  const streetSnacks = [
    ['Veg Momos', allIndia, true, 30],
    ['Paneer Momos', allIndia, true, 30],
    ['Fried Momos', allIndia, true, 35],
    ['Chicken Momos', allIndia, false, 35],
    ['Veg Spring Roll', allIndia, true, 30],
    ['Paneer Kathi Roll', 'Delhi', true, 25],
    ['Egg Kathi Roll', 'West Bengal', false, 25],
    ['Chicken Kathi Roll', 'West Bengal', false, 30],
    ['Veg Frankie', 'Maharashtra', true, 25],
    ['Pav Bhaji', 'Maharashtra', true, 35],
    ['Dabeli', 'Gujarat', true, 20],
    ['Kanda Bhaji Pav', 'Maharashtra', true, 20],
    ['Masala Pav', 'Maharashtra', true, 15],
    ['Bun Maska', 'Maharashtra', true, 10],
    ['Keema Pav', 'Maharashtra', false, 35],
    ['Mirchi Bajji', 'Andhra Pradesh', true, 20],
    ['Punugulu with Ginger Chutney', 'Andhra Pradesh', true, 25],
    ['Bajji Platter', 'Tamil Nadu', true, 25],
    ['Sundal', 'Tamil Nadu', true, 15],
    ['Masala Vadai', 'Tamil Nadu', true, 25],
    ['Banana Bajji', 'Kerala', true, 20],
    ['Parippu Vada', 'Kerala', true, 25],
    ['Pazham Pori', 'Kerala', true, 20],
    ['Kerala Beef Fry with Parotta', 'Kerala', false, 45],
    ['Unniyappam', 'Kerala', true, 30],
    ['Nippattu', 'Karnataka', true, 30],
    ['Kodubale', 'Karnataka', true, 30],
    ['Congress Bun', 'Karnataka', true, 10],
    ['Beguni', 'West Bengal', true, 20],
    ['Telebhaja', 'West Bengal', true, 20],
    ['Mughlai Paratha', 'West Bengal', false, 40],
    ['Singara', 'West Bengal', true, 35],
    ['Khasta Kachori', 'Uttar Pradesh', true, 35],
    ['Matar Kachori', 'Rajasthan', true, 35],
    ['Bhakarwadi', 'Maharashtra', true, 40],
    ['Sabudana Chivda', 'Maharashtra', true, 15],
    ['Murmura Chivda', allIndia, true, 15],
    ['Roasted Makhana', allIndia, true, 10],
    ['Masala Peanuts', allIndia, true, 15],
    ['Paneer 65', allIndia, true, 25],
    ['Gobi 65', allIndia, true, 25],
    ['Gobi Manchurian', allIndia, true, 30],
    ['Veg Manchurian', allIndia, true, 30],
    ['Paneer Chilli Dry', allIndia, true, 25],
    ['Honey Chilli Potato', allIndia, true, 30],
    ['French Fries Masala', allIndia, true, 20],
    ['Chicken 65', 'Tamil Nadu', false, 30],
    ['Chicken Lollipop', allIndia, false, 35],
    ['Chilli Chicken Dry', allIndia, false, 30],
    ['Egg Puff', 'Kerala', false, 30],
    ['Veg Puff', allIndia, true, 25],
    ['Cheese Corn Balls', allIndia, true, 30],
    ['Stuffed Mushroom', allIndia, true, 25],
    ['Nachni Chips', 'Maharashtra', true, 20],
    ['Khakhra with Chai', 'Gujarat', true, 5],
    ['Sev Usal', 'Gujarat', true, 30],
    ['Locho', 'Gujarat', true, 35],
    ['Surti Ghari Bites', 'Gujarat', true, 20],
    ['Poha Jalebi', 'Madhya Pradesh', true, 25],
    ['Garadu Fry', 'Madhya Pradesh', true, 25],
  ];
  for (final row in streetSnacks) {
    add(row[0] as String, 'snacks',
        region: row[1] as String, veg: row[2] as bool, time: row[3] as int);
  }

  // ========================= LUNCH + DINNER MAINS ==========================

  // Vegetable x preparation combos — the everyday core of Indian home food.
  const vegetables = [
    'Aloo', 'Aloo Gobi', 'Aloo Matar', 'Aloo Palak', 'Aloo Baingan',
    'Aloo Shimla Mirch', 'Gobi', 'Gobi Matar', 'Bhindi', 'Baingan',
    'Lauki', 'Tinda', 'Karela', 'Cabbage', 'Cabbage Matar', 'Capsicum',
    'Beans', 'Beans Gajar', 'Gajar Matar', 'Beetroot', 'Kaddu',
    'Raw Banana', 'Arbi', 'Mushroom', 'Mushroom Matar', 'Palak',
    'Methi Aloo', 'Tindora', 'Turai', 'Parwal', 'Gawar', 'Matar',
    'Sweet Corn', 'Soya Chunk', 'Kathal', 'Drumstick', 'Zucchini',
    'Broccoli',
  ];
  const vegForms = [
    ['Sabzi', 20, 'easy'],
    ['Fry', 15, 'easy'],
    ['Curry', 30, 'medium'],
    ['Masala', 35, 'medium'],
  ];
  for (final v in vegetables) {
    for (final f in vegForms) {
      addMeal('$v ${f[0]}', time: f[1] as int, diff: f[2] as String);
    }
  }

  // Dals & legumes.
  const dals = [
    'Toor Dal', 'Moong Dal', 'Masoor Dal', 'Chana Dal', 'Urad Dal',
    'Mixed Dal', 'Panchmel Dal', 'Whole Moong',
  ];
  for (final d in dals) {
    addMeal('$d Tadka', time: 30, diff: 'easy');
    addMeal('$d Fry', time: 30, diff: 'medium');
  }
  addMeal('Dal Makhani', region: 'Punjab', time: 60, diff: 'hard', pop: 88);
  addMeal('Dal Bukhara', region: 'Delhi', time: 60, diff: 'hard');
  addMeal('Rajma Masala', region: 'Punjab', time: 45, diff: 'medium', pop: 86);
  addMeal('Chole Masala', region: 'Punjab', time: 45, diff: 'medium', pop: 85);
  addMeal('Pindi Chole', region: 'Punjab', time: 50, diff: 'medium');
  addMeal('Lobia Curry', time: 40, diff: 'medium');
  addMeal('Kala Chana Curry', time: 45, diff: 'medium');
  addMeal('Moong Sprouts Curry', time: 30, diff: 'easy');
  addMeal('Sambar', region: 'Tamil Nadu', time: 35, diff: 'medium', pop: 84);
  addMeal('Arachuvitta Sambar', region: 'Tamil Nadu', time: 45, diff: 'hard');
  addMeal('Drumstick Sambar', region: 'Tamil Nadu', time: 40, diff: 'medium');
  addMeal('Udupi Sambar', region: 'Karnataka', time: 40, diff: 'medium');
  addMeal('Tomato Rasam', region: 'Tamil Nadu', time: 25, diff: 'easy');
  addMeal('Pepper Rasam', region: 'Tamil Nadu', time: 25, diff: 'easy');
  addMeal('Lemon Rasam', region: 'Tamil Nadu', time: 25, diff: 'easy');
  addMeal('Punjabi Kadhi Pakoda', region: 'Punjab', time: 45, diff: 'medium');
  addMeal('Gujarati Kadhi', region: 'Gujarat', time: 30, diff: 'easy');
  addMeal('Rajasthani Kadhi', region: 'Rajasthan', time: 35, diff: 'medium');
  addMeal('Sindhi Kadhi', region: 'Maharashtra', time: 45, diff: 'medium');

  // Rice dishes.
  const riceDishes = [
    ['Lemon Rice', 'Tamil Nadu', 20],
    ['Tamarind Rice', 'Tamil Nadu', 25],
    ['Curd Rice', 'Tamil Nadu', 15],
    ['Coconut Rice', 'Tamil Nadu', 25],
    ['Tomato Rice', 'Tamil Nadu', 25],
    ['Jeera Rice', allIndia, 20],
    ['Ghee Rice', 'Karnataka', 25],
    ['Vangi Bath', 'Karnataka', 35],
    ['Puliyogare', 'Karnataka', 30],
    ['Bisi Bele Bath Rice', 'Karnataka', 45],
    ['Curd Rice with Tadka', 'Karnataka', 15],
    ['Dal Rice', allIndia, 30],
    ['Rajma Chawal', 'Punjab', 45],
    ['Chole Chawal', 'Punjab', 45],
    ['Kadhi Chawal', 'Punjab', 45],
    ['Sambar Rice', 'Tamil Nadu', 35],
    ['Fried Rice', allIndia, 25],
    ['Schezwan Fried Rice', allIndia, 30],
    ['Paneer Fried Rice', allIndia, 30],
    ['Capsicum Rice', 'Andhra Pradesh', 30],
    ['Gongura Rice', 'Andhra Pradesh', 30],
    ['Pudina Rice', 'Tamil Nadu', 25],
  ];
  for (final row in riceDishes) {
    addMeal(row[0] as String,
        region: row[1] as String,
        time: row[2] as int,
        pop: row[0] == 'Rajma Chawal' ? 90 : null);
  }
  addMeal('Egg Fried Rice', veg: false, time: 25);
  addMeal('Chicken Fried Rice', veg: false, time: 30);

  // Pulao & khichdi.
  const pulaos = [
    'Veg Pulao', 'Matar Pulao', 'Paneer Pulao', 'Kashmiri Pulao',
    'Tawa Pulao', 'Corn Pulao', 'Mushroom Pulao', 'Soya Pulao',
    'Jeera Matar Pulao', 'Coriander Pulao',
  ];
  for (final p in pulaos) {
    addMeal(p,
        region: p == 'Kashmiri Pulao'
            ? 'Kashmir'
            : (p == 'Tawa Pulao' ? 'Maharashtra' : allIndia),
        time: 30,
        diff: 'medium');
  }
  const khichdis = [
    'Moong Dal Khichdi', 'Masala Khichdi', 'Vegetable Khichdi',
    'Bajra Khichdi', 'Daliya Khichdi', 'Gujarati Khichdi', 'Bengali Khichuri',
  ];
  for (final k in khichdis) {
    addMeal(k,
        region: k.contains('Gujarati')
            ? 'Gujarat'
            : (k.contains('Bengali') ? 'West Bengal' : allIndia),
        time: 30,
        diff: 'easy');
  }

  // Biryanis.
  const vegBiryanis = [
    ['Veg Biryani', allIndia],
    ['Paneer Biryani', allIndia],
    ['Mushroom Biryani', allIndia],
    ['Veg Dum Biryani', 'Telangana'],
    ['Kathal Biryani', 'Uttar Pradesh'],
  ];
  for (final row in vegBiryanis) {
    addMeal(row[0], region: row[1], time: 60, diff: 'hard');
  }
  const nonVegBiryanis = [
    ['Chicken Biryani', allIndia, 92],
    ['Hyderabadi Chicken Dum Biryani', 'Telangana', 90],
    ['Mutton Biryani', allIndia, 85],
    ['Egg Biryani', allIndia, 78],
    ['Fish Biryani', 'Kerala', 70],
    ['Prawn Biryani', 'Andhra Pradesh', 70],
    ['Lucknowi Biryani', 'Uttar Pradesh', 75],
    ['Kolkata Biryani', 'West Bengal', 78],
    ['Donne Biryani', 'Karnataka', 80],
    ['Ambur Biryani', 'Tamil Nadu', 75],
    ['Thalassery Biryani', 'Kerala', 75],
  ];
  for (final row in nonVegBiryanis) {
    addMeal(row[0] as String,
        region: row[1] as String, veg: false, time: 70, diff: 'hard',
        pop: row[2] as int);
  }

  // Paneer & veg restaurant-style mains.
  const paneerDishes = [
    ['Paneer Butter Masala', 88],
    ['Paneer Bhurji', 80],
    ['Palak Paneer', 84],
    ['Shahi Paneer', 78],
    ['Kadai Paneer', 80],
    ['Matar Paneer', 82],
    ['Paneer Do Pyaza', 70],
    ['Paneer Tikka Masala', 78],
    ['Paneer Lababdar', 68],
    ['Achari Paneer', 62],
    ['Paneer Kolhapuri', 64],
    ['Paneer Korma', 62],
    ['Chilli Paneer Gravy', 70],
    ['Paneer Pasanda', 60],
  ];
  for (final row in paneerDishes) {
    addMeal(row[0] as String, time: 35, diff: 'medium', pop: row[1] as int);
  }

  const northMains = [
    'Mix Veg Curry', 'Veg Kolhapuri', 'Veg Jalfrezi', 'Navratan Korma',
    'Malai Kofta', 'Lauki Kofta Curry', 'Cabbage Kofta Curry',
    'Dum Aloo', 'Kashmiri Dum Aloo', 'Aloo Tamatar Curry', 'Baingan Bharta',
    'Sarson ka Saag', 'Methi Malai Matar', 'Corn Palak', 'Veg Handi',
    'Stuffed Capsicum', 'Stuffed Tomato', 'Besan Gatte ki Sabzi',
    'Ker Sangri', 'Papad ki Sabzi', 'Sev Tamatar', 'Undhiyu',
    'Veg Makhanwala', 'Khoya Matar',
  ];
  for (final m in northMains) {
    final region = switch (m) {
      'Sarson ka Saag' => 'Punjab',
      'Kashmiri Dum Aloo' => 'Kashmir',
      'Besan Gatte ki Sabzi' || 'Ker Sangri' || 'Papad ki Sabzi' => 'Rajasthan',
      'Sev Tamatar' || 'Undhiyu' => 'Gujarat',
      'Veg Kolhapuri' => 'Maharashtra',
      _ => allIndia,
    };
    addMeal(m, region: region, time: 40, diff: 'medium');
  }

  const southMains = [
    ['Avial', 'Kerala'],
    ['Kerala Veg Stew', 'Kerala'],
    ['Olan', 'Kerala'],
    ['Thoran', 'Kerala'],
    ['Cabbage Thoran', 'Kerala'],
    ['Beans Thoran', 'Kerala'],
    ['Erissery', 'Kerala'],
    ['Pulissery', 'Kerala'],
    ['Beans Poriyal', 'Tamil Nadu'],
    ['Cabbage Poriyal', 'Tamil Nadu'],
    ['Carrot Poriyal', 'Tamil Nadu'],
    ['Potato Poriyal', 'Tamil Nadu'],
    ['Kootu', 'Tamil Nadu'],
    ['Keerai Kootu', 'Tamil Nadu'],
    ['Vatha Kuzhambu', 'Tamil Nadu'],
    ['Kara Kuzhambu', 'Tamil Nadu'],
    ['More Kuzhambu', 'Tamil Nadu'],
    ['Gutti Vankaya Curry', 'Andhra Pradesh'],
    ['Gongura Pachadi', 'Andhra Pradesh'],
    ['Dondakaya Fry', 'Andhra Pradesh'],
    ['Bendakaya Pulusu', 'Andhra Pradesh'],
    ['Palakura Pappu', 'Andhra Pradesh'],
    ['Tomato Pappu', 'Telangana'],
    ['Majjiga Pulusu', 'Telangana'],
    ['Soppu Palya', 'Karnataka'],
    ['Badanekai Ennegai', 'Karnataka'],
    ['Majjige Huli', 'Karnataka'],
    ['Kosambari', 'Karnataka'],
  ];
  for (final row in southMains) {
    addMeal(row[0], region: row[1], time: 30, diff: 'medium');
  }

  const bengaliMains = [
    ['Aloo Posto', true],
    ['Shukto', true],
    ['Begun Bhaja', true],
    ['Cholar Dal', true],
    ['Dhokar Dalna', true],
    ['Potol Posto', true],
    ['Macher Jhol', false],
    ['Shorshe Ilish', false],
    ['Chingri Malai Curry', false],
    ['Doi Maach', false],
    ['Kosha Mangsho', false],
    ['Bengali Egg Curry', false],
  ];
  for (final row in bengaliMains) {
    addMeal(row[0] as String,
        region: 'West Bengal', veg: row[1] as bool, time: 40, diff: 'medium');
  }

  // Non-veg protein x preparation combos.
  const nonVegCombos = [
    ['Chicken', ['Curry', 'Masala', 'Fry', 'Roast', 'Korma', 'Do Pyaza', 'Kolhapuri', 'Chettinad', 'Tikka Masala', 'Butter Masala', 'Saagwala', 'Stew']],
    ['Mutton', ['Curry', 'Masala', 'Fry', 'Roast', 'Korma', 'Do Pyaza', 'Rogan Josh', 'Keema Matar', 'Chettinad', 'Stew']],
    ['Fish', ['Curry', 'Fry', 'Masala', 'Moilee', 'Pulusu', 'Gassi', 'Amritsari Fried']],
    ['Prawn', ['Curry', 'Fry', 'Masala', 'Ghee Roast', 'Balchao']],
    ['Egg', ['Curry', 'Masala', 'Bhurji Gravy', 'Roast', 'Korma']],
  ];
  for (final row in nonVegCombos) {
    final protein = row[0] as String;
    for (final form in row[1] as List) {
      final name = '$protein $form';
      final region = switch (form) {
        'Chettinad' => 'Tamil Nadu',
        'Rogan Josh' => 'Kashmir',
        'Moilee' || 'Stew' => 'Kerala',
        'Pulusu' => 'Andhra Pradesh',
        'Gassi' || 'Ghee Roast' => 'Karnataka',
        'Balchao' => 'Goa',
        'Amritsari Fried' => 'Punjab',
        'Kolhapuri' => 'Maharashtra',
        _ => allIndia,
      };
      addMeal(name,
          region: region,
          veg: false,
          time: protein == 'Egg' ? 30 : 50,
          diff: protein == 'Egg' ? 'medium' : 'hard',
          pop: name == 'Butter Chicken' ? 92 : null);
    }
  }
  addMeal('Butter Chicken', region: 'Punjab', veg: false, time: 50,
      diff: 'hard', pop: 92);
  addMeal('Tandoori Chicken', region: 'Punjab', veg: false, time: 45,
      diff: 'medium', pop: 85);
  addMeal('Chicken Ghee Roast', region: 'Karnataka', veg: false, time: 50,
      diff: 'hard');
  addMeal('Goan Fish Curry', region: 'Goa', veg: false, time: 40,
      diff: 'medium');
  addMeal('Pork Vindaloo', region: 'Goa', veg: false, time: 60, diff: 'hard');
  addMeal('Laal Maas', region: 'Rajasthan', veg: false, time: 70,
      diff: 'hard');
  addMeal('Nihari', region: 'Delhi', veg: false, time: 90, diff: 'hard');
  addMeal('Haleem', region: 'Telangana', veg: false, time: 90, diff: 'hard');
  addMeal('Keema Pav Dinner', region: 'Maharashtra', veg: false, time: 40,
      diff: 'medium');

  // Roti-combo style dinners & light dinners.
  const dinnerOnly = [
    ['Roti with Mixed Veg Sabzi', allIndia, true, 35],
    ['Roti with Dal Tadka', allIndia, true, 35],
    ['Phulka with Bhindi Fry', allIndia, true, 30],
    ['Jowar Bhakri with Pitla', 'Maharashtra', true, 35],
    ['Bajra Roti with Baingan Bharta', 'Rajasthan', true, 40],
    ['Makki di Roti with Sarson da Saag', 'Punjab', true, 50],
    ['Dal Baati Churma', 'Rajasthan', true, 75],
    ['Veg Thali Style Dinner', allIndia, true, 60],
    ['Pav Bhaji Dinner', 'Maharashtra', true, 35],
    ['Pulka with Tomato Pappu', 'Telangana', true, 35],
    ['Neer Dosa with Veg Kurma', 'Karnataka', true, 35],
    ['Parotta with Salna', 'Tamil Nadu', true, 45],
    ['Kerala Parotta with Veg Kurma', 'Kerala', true, 45],
    ['Appam with Veg Stew', 'Kerala', true, 40],
    ['Tomato Soup with Garlic Bread', allIndia, true, 20],
    ['Sweet Corn Soup', allIndia, true, 20],
    ['Hot and Sour Veg Soup', allIndia, true, 20],
    ['Veg Clear Soup', allIndia, true, 15],
    ['Palak Soup', allIndia, true, 20],
    ['Veg Hakka Noodles', allIndia, true, 25],
    ['Schezwan Noodles', allIndia, true, 25],
    ['Paneer Hakka Noodles', allIndia, true, 30],
    ['Veg Chowmein', allIndia, true, 25],
    ['Masala Maggi', allIndia, true, 10],
    ['Vegetable Pasta', allIndia, true, 25],
    ['White Sauce Pasta', allIndia, true, 30],
    ['Red Sauce Pasta', allIndia, true, 30],
    ['Grilled Veg Salad Bowl', allIndia, true, 20],
    ['Quinoa Veg Bowl', allIndia, true, 25],
    ['Chicken Soup', allIndia, false, 30],
    ['Chicken Hakka Noodles', allIndia, false, 30],
    ['Egg Chowmein', allIndia, false, 25],
    ['Chicken Shawarma Roll', allIndia, false, 35],
    ['Kerala Parotta with Chicken Curry', 'Kerala', false, 50],
    ['Parotta with Chicken Salna', 'Tamil Nadu', false, 50],
  ];
  for (final row in dinnerOnly) {
    add(row[0] as String, 'dinner',
        region: row[1] as String, veg: row[2] as bool, time: row[3] as int);
  }

  // ============================ OUTPUT ====================================

  items.sort((a, b) =>
      (a['category'] as String).compareTo(b['category'] as String) != 0
          ? (a['category'] as String).compareTo(b['category'] as String)
          : (a['name'] as String).compareTo(b['name'] as String));

  final byCategory = <String, int>{};
  for (final item in items) {
    byCategory.update(item['category'] as String, (v) => v + 1,
        ifAbsent: () => 1);
  }

  final outFile = File('assets/data/food_dataset.json');
  outFile.createSync(recursive: true);
  outFile.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(items));

  stdout.writeln('Wrote ${items.length} dishes to ${outFile.path}');
  byCategory.forEach((k, v) => stdout.writeln('  $k: $v'));

  if (items.length < 1000) {
    stderr.writeln('ERROR: dataset has ${items.length} items (< 1000).');
    exitCode = 1;
  }
}
