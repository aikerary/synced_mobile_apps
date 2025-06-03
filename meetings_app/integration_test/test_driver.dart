import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() => integrationDriver(
      responseDataCallback: (data) async {
        if (data != null) {
          // You could save data from the tests to a file here
          print('Test data: $data');
        }
      },
    );
