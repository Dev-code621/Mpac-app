
class StateModel {
  static String className = "StateModel";

  final String name;
  final List<State> states;

  final String? stateCode;

  StateModel({required this.name, required this.states, this.stateCode});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
        name: json['name'],
        states: getStates(
          json['states'],
        ),
        stateCode: json['state_code'],);
  }

  static List<State> getStates(json) {
    List<State> states = [];
    for (var item in json) {
      states.add(State.fromJson(item));
    }
    return states;
  }
}

class State {
  static String className = "State";

  final String name;
  final List<String> cities;
  final String stateCode;

  State({required this.name, required this.cities, required this.stateCode});

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
        name: json['name'],
        stateCode: json['state_code'],
        cities: getCities(json['cities']),);
  }

  static List<String> getCities(json) {
    List<String> states = [];
    for (var item in json) {
      states.add(item.toString());
    }
    return states;
  }
}
