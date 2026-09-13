class Calificacion {
  final String localId;
  String? serverId;
  String studentName;
  String subject;
  double grade;
  String comment;
  DateTime updatedAt;
  bool isSynced;
  bool isDeleted;

  Calificacion({
    required this.localId,
    this.serverId,
    required this.studentName,
    required this.subject,
    required this.grade,
    this.comment = '',
    required this.updatedAt,
    this.isSynced = false,
    this.isDeleted = false,
  });

 
  static const double passingGrade = 3.0;

  bool get isPassing => grade >= passingGrade;

  Calificacion copyWith({
    String? serverId,
    String? studentName,
    String? subject,
    double? grade,
    String? comment,
    DateTime? updatedAt,
    bool? isSynced,
    bool? isDeleted,
  }) {
    return Calificacion(
      localId: localId,
      serverId: serverId ?? this.serverId,
      studentName: studentName ?? this.studentName,
      subject: subject ?? this.subject,
      grade: grade ?? this.grade,
      comment: comment ?? this.comment,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'localId': localId,
      'serverId': serverId,
      'studentName': studentName,
      'subject': subject,
      'grade': grade,
      'comment': comment,
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
    };
  }

  factory Calificacion.fromDbMap(Map<String, dynamic> map) {
    return Calificacion(
      localId: map['localId'] as String,
      serverId: map['serverId'] as String?,
      studentName: map['studentName'] as String,
      subject: map['subject'] as String,
      grade: (map['grade'] as num).toDouble(),
      comment: (map['comment'] ?? '') as String,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      isSynced: (map['isSynced'] as int) == 1,
      isDeleted: (map['isDeleted'] as int) == 1,
    );
  }

 
  factory Calificacion.fromServerJson(Map<String, dynamic> json, {String? localId}) {
    return Calificacion(
      localId: localId ?? json['id'] as String,
      serverId: json['id'] as String,
      studentName: json['studentName'] as String,
      subject: json['subject'] as String,
      grade: (json['grade'] as num).toDouble(),
      comment: (json['comment'] ?? '') as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: true,
      isDeleted: false,
    );
  }
}
