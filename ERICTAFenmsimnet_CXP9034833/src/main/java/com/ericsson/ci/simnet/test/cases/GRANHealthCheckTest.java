package com.ericsson.ci.simnet.test.cases;

import javax.inject.Inject;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import com.ericsson.ci.simnet.test.operators.CLIScriptExecutionOperator;
import com.ericsson.ci.simnet.test.operators.ScriptExecutionOperator;
import com.ericsson.cifwk.taf.TestCase;
import com.ericsson.cifwk.taf.TorTestCaseHelper;
import com.ericsson.cifwk.taf.annotations.*;
import com.ericsson.cifwk.taf.guice.OperatorRegistry;

/**
 * Executes scripts and verify expected output
 */
public class GRANHealthCheckTest extends TorTestCaseHelper implements TestCase {

    @Inject
    OperatorRegistry<ScriptExecutionOperator> operatorRegistry;

    @BeforeSuite
    public void initialise() {
        assertTrue(CLIScriptExecutionOperator.initialise());
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
    @Test(groups = { "Acceptance" })
    @DataDriven(name = "GRANHealthCheckTest")
    @Context(context = { Context.CLI })
    public void verifyScriptExecution(@Input("command") final String command, @Output("expectedExitCode") final int expectedExitCode) {

        final ScriptExecutionOperator seOperator = operatorRegistry.provide(ScriptExecutionOperator.class);
        final int scriptExecutionExitCode = seOperator.verifyScriptExecution(command);

        final boolean testCondition = scriptExecutionExitCode == expectedExitCode;

        if (!testCondition) {
            throw new TestCaseException("Returned exit code: " + scriptExecutionExitCode + ",  while expecting exit code: " + expectedExitCode);
        }

        assertTrue(testCondition);

   }
}
