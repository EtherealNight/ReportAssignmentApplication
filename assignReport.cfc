<cfcomponent>
<!---Check Employee Assignment--->

<!--- Function To Get Reports List--->
<cffunction name="reportsList" returntype="any" access="remote">
 <!---Reports List DG Query--->
    <cfquery name="qryReportsList" datasource="Main_Dev">
    SELECT Report_Name
    FROM Report_Master_List
    Order By Report_Name
    </cfquery>
    <cfreturn qryReportsList>
    </cffunction>
    
  <!--- Function To Get List of Employees--->
  <cffunction name="getEmployeeList" access="remote" >
    <cfquery name="qryGetEmployeeList" datasource="Main_Dev">
    SELECT ID, fname + ' ' + lname AS employeeName 							
    FROM First_Admin
   WHERE (fname IS NOT NULL)
   AND (lname IS NOT NULL)
   Order By employeeName
    </cfquery>
  <cfreturn qryGetEmployeeList>
  </cffunction>
  <!---Lets Get The Employees Assigned to the Selected Report--->
  <cffunction name="getReportsAssignedToEmployees" access="remote" >
  <cfargument name="reportName" hint="passes report name from flex to CF" >
  <cfquery name="qryGetAssignedEmployees" datasource="Main_Dev">
  SELECT employeeName, dateCreated
  FROM [Services_Dev].[dbo].[AssignedReports]
  WHERE reportName = '#arguments.reportName#'
  </cfquery>
  <cfreturn qryGetAssignedEmployees >
  </cffunction>
  
  <!---Get the currently assigned Reports. This grabs a list of reports currently assigned and returns it to the UI for the data drill down--->
  <cffunction name="getReportsCurrentlyAssigned" access="remote">
  <cfquery name="qrygetReportsCurrentlyAssigned" datasource="Main_Dev">
  SELECT DISTINCT reportName 
  FROM AssignedReports
  Order By reportName
  </cfquery>
  <cfreturn qryGetReportsCurrentlyAssigned >
  </cffunction>
  
   <!---Lets Get The Employees Assigned to the Selected Report (populates the assigned employee box in flex) --->
  <cffunction name="getAssignedEmployees2" access="remote" >
  <cfquery name="qryGetAssignedEmployees2" datasource="Main_Dev">
  SELECT DISTINCT employeeName
  FROM AssignedReports
  Order By employeeName
  </cfquery>
  <cfreturn qryGetAssignedEmployees2 >
  </cffunction>
  
   <!---Lets Get The Reports Assigned to the Selected employee (populates the assigned reports box in flex) --->
  <cffunction name="getAssignedReports" access="remote" >
  <cfargument name="employeeName" >
  <cfquery name="qryGetAssignedReports" datasource="Main_Dev">
	SELECT 
     reportName, dateCreated  
  	FROM [Services_Dev].[dbo].[AssignedReports]
  	WHERE employeeName = '#arguments.employeeName#'
  </cfquery>
  <cfreturn qryGetAssignedReports >
  </cffunction>
  
  <!--- Lets delete the selected assignment by selected employee--->
  <cffunction name="deleteEmployeeAssignment" access="remote" >
   <cfargument name="employeeName" >
  <cfargument name="reportName">
  <cfquery name="qryDeleteEmployeeAssignment" datasource="Main_Dev">
  DELETE FROM [Services_Dev].[dbo].[AssignedReports]
      WHERE employeeName = '#arguments.employeeName#' and reportName='#reportName#'
  </cfquery>
  </cffunction>
 
    <!---Employee DataGrid Query--->
 	<cffunction name="getAssignmentByEmployee" access="remote" returntype="any">
	<cfquery name="qEmployeeAssignments" datasource="Main_Dev">									<!---Control Grid Query. Grabs all employees assigned to a report--->
    SELECT assignmentID, employeeID, employeeName, reportName, reportDescrip, dateCreated 					<!---Query criteria: first name, last name, reportName, reportDescrip --->
    FROM AssignedReports																					<!--- Table being referenced --->
	</cfquery>
    <cfreturn qEmployeeAssignments>
</cffunction>

	<!---Assign Employee to Report Method--->
	<cffunction name="assignReport" access="remote"  >														<!---Method assignReport runs to create emp/report assign--->
        <!--- <cfargument name="employeeID" type="numeric" default="11299">	--->							<!---employeeID variable--->
       <cfargument name="ID" type="any">
        <cfargument name="employeeName" type="any" default="Michael">										<!---first name variable: fName--->
        <cfargument name="Report_Name" type="any" default="Sample Report">									<!---report name variable: reportName --->
       <cfset access_level = '1' >
        <cftransaction> 																					
        <!---Check For Existing Assignment--->
       <!--- <cfquery name="qryReportAlreadyAssigned" datasource="Main_Dev" dbname="Services_Dev">			<!---This query checks for prior employee assignment--->
        SELECT *
  		FROM [Services_Dev].[dbo].[AssignedReports]																		<!---Checks based on this assignedReport and employeeID--->
  		WHERE assignedReport = '2' AND employeeID = '11299'
        </cfquery> 
        <!---If record count is zero, run insert query to assign employee to report--->
        <cfif qryAlreadyAssigned.recordCount eq 0>																					<!---If the check of a record count is 0, insert initiated--->
        <!---Assignment Query--->
       --->
        <cfquery name="qryAssignReport" datasource="Services_Dev" dbname="Services_Dev">
         INSERT INTO AssignedReports (employeeID, employeeName, reportName, accessLevel)
   		
         VALUES ( <cfqueryparam cfsqltype="cf_sql_int" value="#arguments.ID#">,
    			<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.employeeName#">,
         	    <cfqueryparam cfsqltype="cf_sql_varchar" value="#Report_Name#">,
                <cfqueryparam cfsqltype="cf_sql_integer" value="#access_level#"> )
        </cfquery>
       <!--- <cfelse>
        <!---User provided with error message for attempting duplicate assignment to employee--->
        <h2 style="color:#C33">#reportName# already assigned to selected employee. Please try new assignment</h2>
        </cfif> --->
    </cftransaction>
	</cffunction>
    
    <!---This function is designed to delete employee assignment to the selected report--->
    <!---Alert Box Goes here to confirm user wants to delete report association before initiating function below--->
 <cffunction name="DeleteReportAssignment" access="remote" description="deletes selected employee from selected report assignment" returntype="void">
    <cftransaction>																												<!---Declares the query as a transaction to the DB system--->
    <cfquery name="qryDeleteEmployeeAssignment" datasource="Corp_Dev" dbname="Corp_Dev_DB">
    DELETE FROM [Corp_Services_Dev].[dbo].[AssignedReports]
      WHERE employeeID ='11283' AND assignedReport = '1'
    </cfquery>
    </cftransaction>
    </cffunction>
    
    <cffunction name="assignEmployee" access="remote" returntype="string">
    <cfquery name="qryAssignEmployee" datasource="Main_Dev" dbname="Services_Dev">	
      INSERT INTO AssignedReports (employeeID,employeeName, reportName)
   		
         VALUES (<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.ID#">,
         		 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.employee2#">, 
    			 <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Report_Name2#">)
    </cfquery>
    </cffunction>
    
    <!---Add New Report To the DB --->
    <cffunction name="addNewReport" access="remote" returntype="any">
    <cfargument name="fmReportName" type="any" required="yes">
    <cfargument name="fmReportCategory" type="any" required="yes">
    <cfargument name="fmReportDescrip" type="any" required="yes">
    <cfquery name="qryAddNewReport" datasource="Services_Dev">
    INSERT INTO [Services_Dev].[dbo].[Report_Master_List]
           ([Report_Name]
           ,[Category]
           ,[Report_Desc] )
     VALUES
           (<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fmReportName#">,
           <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fmReportCategory#">,
           <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.fmReportDescrip#">)
    </cfquery>
    </cffunction>
    
</cfcomponent>
