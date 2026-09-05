/// Shared rating display — hide fake scores when there are no reviews.
String monkRatingLabel(double rating, int reviewCount) {
  if (reviewCount <= 0) return 'Үнэлгээгүй';
  return '${rating.toStringAsFixed(1)} · $reviewCount';
}

bool monkHasReviews(int reviewCount) => reviewCount > 0;
