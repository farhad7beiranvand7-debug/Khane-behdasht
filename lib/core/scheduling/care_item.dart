import '../calendar/jalali_birth_date.dart';

enum ScheduleCategory { vaccination, care, pregnancy }

enum ScheduleStatus { upcoming, due, overdue, completed }

class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    this.description,
    this.dose,
    this.completedDate,
  });

  final String id;
  final String title;
  final ScheduleCategory category;
  final JalaliBirthDate dueDate;
  final String? description;
  final String? dose;
  final JalaliBirthDate? completedDate;

  bool get isCompleted => completedDate != null;

  ScheduleItem copyWith({JalaliBirthDate? completedDate}) => ScheduleItem(
        id: id,
        title: title,
        category: category,
        dueDate: dueDate,
        description: description,
        dose: dose,
        completedDate: completedDate,
      );
}
