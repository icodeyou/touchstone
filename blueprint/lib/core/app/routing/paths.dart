class Path {
  const Path({required this.name, required this.location});

  final String name;
  final String location;
}

class Paths {
  static const home = Path(name: 'home', location: '/home');
}
