import 'package:flutter_test/flutter_test.dart';

import '../test_utils/general_helper.dart';

void main() async {
  await ImmichTestHelper.initialize();

  group("Login tests", () {
    immichWidgetTest("Test correct credentials", (tester, helper) async {
      await helper.loginHelper.waitForLoginScreen();
      await helper.loginHelper.acknowledgeNewServerVersion();
      await helper.loginHelper.enterCredentialsOf(.testInstance);
      await helper.loginHelper.pressLoginButton();
      await helper.loginHelper.assertLoginSuccess();
    });

    immichWidgetTest("Test login with wrong password", (tester, helper) async {
      await helper.loginHelper.waitForLoginScreen();
      await helper.loginHelper.acknowledgeNewServerVersion();
      await helper.loginHelper.enterCredentialsOf(.testInstanceButWithWrongPassword);
      await helper.loginHelper.pressLoginButton();
      await helper.loginHelper.assertLoginFailed();
    });

    immichWidgetTest("Test login with wrong server URL", (tester, helper) async {
      await helper.loginHelper.waitForLoginScreen();
      await helper.loginHelper.acknowledgeNewServerVersion();
      await helper.loginHelper.enterCredentialsOf(.wrongInstanceUrl);
      await helper.loginHelper.pressLoginButton();
      await helper.loginHelper.assertLoginFailed();
    });
  });
}
