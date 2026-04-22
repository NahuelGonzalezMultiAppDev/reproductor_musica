enum Genre {
  pop('Pop'),
  rock('Rock'),
  hipHop('Hip-Hop'),
  electronic('Electronic'),
  rnb('R&B'),
  jazz('Jazz'),
  classical('Classical'),
  reggaeton('Reggaetón'),
  latin('Latin'),
  indie('Indie'),
  metal('Metal'),
  country('Country'),
  folk('Folk'),
  soundtrack('Soundtrack'),
  other('Other');

  const Genre(this.label);
  final String label;

  static Genre? fromLabel(String label) {
    for (final g in Genre.values) {
      if (g.label.toLowerCase() == label.toLowerCase()) return g;
    }
    return null;
  }
}
