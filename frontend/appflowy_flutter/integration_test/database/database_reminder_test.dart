import 'package:appflowy/workspace/presentation/notifications/widgets/notification_item.dart';
import 'package:appflowy/workspace/presentation/widgets/date_picker/widgets/reminder_selector.dart';
import 'package:appflowy_backend/protobuf/flowy-database2/field_entities.pbenum.dart';
import 'package:appflowy_backend/protobuf/flowy-folder/protobuf.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../util/database_test_op.dart';
import '../util/util.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('reminder in database', () {
    testWidgets('add date field and add reminder', (tester) async {
      await tester.initializeAppFlowy();
      await tester.tapGoButton();

      await tester.createNewPageWithNameUnderParent(layout: ViewLayoutPB.Grid);

      // Invoke the field editor
      await tester.tapGridFieldWithName('Type');
      await tester.tapEditFieldButton();

      // Change to date type
      await tester.tapSwitchFieldTypeButton();
      await tester.selectFieldType(FieldType.DateTime);
      await tester.dismissFieldEditor();

      // Open date picker
      await tester.tapCellInGrid(rowIndex: 0, fieldType: FieldType.DateTime);
      await tester.findDateEditor(findsOneWidget);

      // Select date
      await tester.selectLastDateInPicker();

      // Select Time of event reminder
      await tester.selectReminderOption(ReminderOption.atTimeOfEvent);

      // Expect Time of event to be displayed
      tester.expectSelectedReminder(ReminderOption.atTimeOfEvent);

      // Dismiss the cell/date editor
      await tester.dismissCellEditor();

      // Open date picker again
      await tester.tapCellInGrid(rowIndex: 0, fieldType: FieldType.DateTime);
      await tester.findDateEditor(findsOneWidget);

      // Expect Time of event to be displayed
      tester.expectSelectedReminder(ReminderOption.atTimeOfEvent);

      // Dismiss the cell/date editor
      await tester.dismissCellEditor();

      // Open "Upcoming" in Notification hub
      await tester.openNotificationHub(tabIndex: 1);

      // Expect 1 notification
      tester.expectNotificationItems(1);
    });

    testWidgets('navigate from reminder to open row', (tester) async {
      await tester.initializeAppFlowy();
      await tester.tapGoButton();

      await tester.createNewPageWithNameUnderParent(layout: ViewLayoutPB.Grid);

      // Invoke the field editor
      await tester.tapGridFieldWithName('Type');
      await tester.tapEditFieldButton();

      // Change to date type
      await tester.tapSwitchFieldTypeButton();
      await tester.selectFieldType(FieldType.DateTime);
      await tester.dismissFieldEditor();

      // Open date picker
      await tester.tapCellInGrid(rowIndex: 0, fieldType: FieldType.DateTime);
      await tester.findDateEditor(findsOneWidget);

      // Select date
      await tester.selectLastDateInPicker();

      // Select Time of event reminder
      await tester.selectReminderOption(ReminderOption.atTimeOfEvent);

      // Expect Time of event to be displayed
      tester.expectSelectedReminder(ReminderOption.atTimeOfEvent);

      // Dismiss the cell/date editor
      await tester.dismissCellEditor();

      // Open date picker again
      await tester.tapCellInGrid(rowIndex: 0, fieldType: FieldType.DateTime);
      await tester.findDateEditor(findsOneWidget);

      // Expect Time of event to be displayed
      tester.expectSelectedReminder(ReminderOption.atTimeOfEvent);

      // Dismiss the cell/date editor
      await tester.dismissCellEditor();

      // Create and Navigate to a new document
      await tester.createNewPageWithNameUnderParent();
      await tester.pumpAndSettle();

      // Open "Upcoming" in Notification hub
      await tester.openNotificationHub(tabIndex: 1);

      // Expect 1 notification
      tester.expectNotificationItems(1);

      // Tap on the notification
      await tester.tap(find.byType(NotificationItem));
      await tester.pumpAndSettle();

      // Expect to see Row Editor Dialog
      tester.expectToSeeRowDetailsPageDialog();
    });
  });
}
