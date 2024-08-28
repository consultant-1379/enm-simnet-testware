package com.ericsson.ci.simnet.test.cases;

import javax.inject.Inject;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import com.ericsson.ci.simnet.test.operators.NetsimHealthCheckExecutionOperator;
import com.ericsson.ci.simnet.test.operators.netsimHCScriptExecutionOperator;
import com.ericsson.cifwk.taf.TestCase;
import com.ericsson.cifwk.taf.TorTestCaseHelper;
import com.ericsson.cifwk.taf.annotations.*;
import com.ericsson.cifwk.taf.guice.OperatorRegistry;

/**
 * Executes scripts and verify expected output
 */
public class GRANCompareData extends TorTestCaseHelper implements TestCase {

 @Inject
 OperatorRegistry<netsimHCScriptExecutionOperator> operatorRegistry;

 @BeforeSuite
 public void initialise() {
  assertTrue(NetsimHealthCheckExecutionOperator.initialise());
 }

 /**
  * Executes scripts on a remote server which defined in host.properties file.
  *
  * @DESCRIPTION Verify the script executions
  * @PRE Copy the scripts to remote server be tested
  * @VUsers 1
  * @PRIORITY HIGH Note: NETSUP-12644 Check html report for full explanation behind failures
  */
 @TestId(id = "NSS-12644", title = "Verify the script executions")
 @Test(groups = {"Acceptance"})
 @DataDriven(name = "GRANCompareData")
 @Context(context = {Context.CLI})
 public void verifyScriptExecution(@Input("command") final String command, @Output("expectedExitCode") final int expectedExitCode) {

  final netsimHCScriptExecutionOperator seOperator = operatorRegistry.provide(netsimHCScriptExecutionOperator.class);
  final int scriptExecutionExitCode = seOperator.verifyScriptExecution(command);

  final boolean testCondition = scriptExecutionExitCode == expectedExitCode;

  if (!testCondition) {
   throw new TestCaseException("Returned exit code: " + scriptExecutionExitCode + ",  while expecting exit code: " + expectedExitCode);
  }

  assertTrue(testCondition);

 }
}