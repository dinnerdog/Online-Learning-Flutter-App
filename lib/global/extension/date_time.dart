import 'package:intl/intl.dart';

final formattedDate = DateFormat('dd/MM/yyyy – kk:mm');

final formattedDateOnly = DateFormat('dd/MM/yyyy');


extension DateTimeExtensions on DateTime {

  String formalize() {
    return formattedDate.format(this);
  }

  String formalizeOnly() {
    return formattedDateOnly.format(this);
  }

  


  String informalTime() {
    final Duration diff = DateTime.now().difference(this);

    if (diff.inDays < 1) {
      if (diff.inHours < 1 && diff.inHours > 0) {
        return '${diff.inMinutes} minutes ago';
      } else {
        return DateFormat('MMMM dd kk:mm').format(this);
      }
    } else if (diff.inDays < 3) {
      return '${diff.inDays} days ago';
    } else if (diff.inHours > 1 && diff.inHours < 23) {
      return DateFormat('MMMM dd kk:mm').format(this);
    } else {
      return DateFormat('MMMM dd, yyyy').format(this);
    }
  }
}
