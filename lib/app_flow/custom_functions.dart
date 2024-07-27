

String returnProfileGreeting(DateTime timestamp) {
  // return "morning" if it is morning, "afternoon" if afternoon and "night" if it is night
  var hour = timestamp.hour;
  if (hour >= 0 && hour < 12) {
    return "Buongiorno,";
  } else if (hour >= 12 && hour < 17) {
    return "Buon pomeriggio,";
  } else {
    return "Buonasera,";
  }
}
