class StepCandidate {
  final int id;
  final String title;
  final String imageurl;

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'imageurl': imageurl};

  @override
  String toString() {
    Map<String, dynamic> temp = toJson();
    return temp.toString();
  }

  StepCandidate(
      {required this.id, required this.title, required this.imageurl});

  factory StepCandidate.fromJson(Map<String, dynamic> data) {
    // ! there's a problem with this code (see below)
    final id = data['id'];
    final title = data['title'];
    final imageurl = data['image_url'];

    return StepCandidate(id: id, title: title, imageurl: imageurl);
  }
}

class Steppy {
  final int stepId;
  final List<StepCandidate> candidates;
  final bool allowBoth;
  final bool allowNone;

  Map<String, dynamic> toJson() => {
        'step_id': stepId,
        'step_candidates': candidates,
        'allow_none_selection': allowNone,
        'allow_both_selection': allowBoth,
      };

  @override
  String toString() {
    Map<String, dynamic> temp = toJson();
    return temp.toString();
  }

  Steppy(
      {required this.stepId,
      required this.candidates,
      required this.allowBoth,
      required this.allowNone});

  factory Steppy.fromJson(Map<String, dynamic> data) {
    final stepId = data['step_number'];
    final candidates = data['step_candidates'];
    final allowBoth = data['allow_both_selection'];
    final allowNone = data['allow_none_selection'];

    List<StepCandidate> itemsList = List<StepCandidate>.from(candidates
        .map<StepCandidate>((dynamic i) => StepCandidate.fromJson(i)));

    return Steppy(
        stepId: stepId,
        candidates: itemsList,
        allowBoth: allowBoth,
        allowNone: allowNone);
  }
}

class Game {
  final String gameId;
  final Steppy step;

  Game({required this.gameId, required this.step});

  factory Game.fromJson(Map<String, dynamic> data) {
    final gameId = data['game_id'];
    final steppy = Steppy.fromJson(data);

    return Game(gameId: gameId, step: steppy);
  }

  Map<String, dynamic> toJson() => {
        'game_id': gameId,
        'step': step,
      };

  @override
  String toString() {
    Map<String, dynamic> temp = toJson();
    return temp.toString();
  }
}
