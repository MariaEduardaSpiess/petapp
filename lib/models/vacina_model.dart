class VacinaModel {
  VacinaModel({this.data, this.nome, this.dose, this.totalDoses});

  factory VacinaModel.fromJson(Map<String, dynamic> json) {
    return VacinaModel(nome: json['nome'], data: json['data'], dose: json['dose'], totalDoses: json['totalDoses']);
  }

  final String nome;
  final String data;
  final int dose;
  final int totalDoses;
}
