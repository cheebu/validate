<cfcomponent output="true">

	<!--- 
		Author:			William Rae
		Company:		Wilson Interactive
		First published:	July 2014	
		Last update:		April 11, 2018
		Version			0.073
		github repository: 	https://github.com/cheebu/validate
	--->	

	<!---- init ---->
	<cffunction name="init" returntype="any">
		<cfargument name="dsn" required="true" type="string" > 
		<cfset variables.dsn = arguments.dsn />
		<!---- return success ---->
		<cfreturn this />
	</cffunction>

	<cffunction name="formCheck" access="public" output="false" returntype="array" >
		<cfargument name="form" type="struct" required="true" >
		<cfargument name="rules" type="array" required="true" >

		<cfset var lstError = "" >
		<cfset var arrValidate = arrayNew(1) >

		<cfif arrayLen(arguments.rules) AND structKeyExists(arguments ,'form') AND NOT structIsEmpty(arguments.form) >
		
			<cfloop from="1" to="#arrayLen(arguments.rules)#" index="nRow" >

				<cfscript>
				
				/* reset the match boolean to false */
				bMatch = false;

				ruleType =  listGetAt(arguments.rules[nRow],1,",");
	
				// writedump(ruletype);

				if (ruletype eq "required") {
					
					bMatch = true;

					variables.fieldName = listGetAt(arguments.rules[nRow],2,",");
					if (structKeyExists(arguments.form, "#variables.fieldName#")){
						if (NOT len(arguments.form[variables.fieldName] )) {	
							lstError = listAppend(lstError,nRow,",");
						}												
					} else {
						lstError = listAppend(lstError,nRow,",");			
					}

				}
				
				if (ruletype eq "digits_only") {
					
					bMatch = true;
					
					variables.fieldName = listGetAt(arguments.rules[nRow],2,",");
					if (structKeyExists(arguments.form, "#variables.fieldName#")){
						if (NOT isNumeric(arguments.form[variables.fieldName])) {
							lstError = listAppend(lstError,nRow,",");
						}
					} else {
						lstError = listAppend(lstError,nRow,",");
					}
				}

				if (ruletype eq "same_as") {
					// this tests to see if field 1 and field 2 are the same when a user confirms a password
					bMatch = true;

					variables.fieldName1 = listGetAt(arguments.rules[nRow],2,",");
					variables.fieldName2 = listGetAt(arguments.rules[nRow],3,",");
					if (structKeyExists(arguments.form, "#variables.fieldName1#") AND structKeyExists(arguments.form, "#variables.fieldName2#") ){
						if (arguments.form[variables.fieldName1] neq arguments.form[variables.fieldName2] ) {	
							lstError = listAppend(lstError,nRow,",");
						}
					} else {
						lstError = listAppend(lstError,nRow,",");			
					}
				}

				if (ruletype eq "valid_email") {
					bMatch = true;
					variables.fieldName = listGetAt(arguments.rules[nRow],2,",");
					if (structKeyExists(arguments.form, "#variables.fieldName#")){
						if (NOT isValid('email', arguments.form[variables.fieldName] )) {
							lstError = listAppend(lstError,nRow,",");			
						}
					}
				}

				if (ruletype eq "valid_uuid") {
					bMatch = true;
					if (structKeyExists(arguments.form, "#variables.fieldName#")){
						if (NOT isValid('uuid', arguments.form[variables.fieldName] )) {
							lstError = listAppend(lstError,nRow,",");			
						}
					}
				}

				if (left(ruletype,6) eq "length") {
					// this tests to see if the length of the field is within the limits of the 
					bMatch = true;

					variables.fieldName = listGetAt(arguments.rules[nRow],2,",");
					
					if (findNoCase('-',ruletype,1)) {
					// if in here, field must be is between lengths	
					
						sRuleType 	= replaceNoCase(ruletype,'length','','all');
						sRuleType 	= replaceNoCase(ruletype,'=','','all');
					
						nLeftValue 	= listGetAt(sRuleType,1,'-');		
						nRightValue = listGetAt(sRuleType,2,'-');
					
						if (len(arguments.form[variables.fieldName]) gte nLeftValue AND len(arguments.form[variables.fieldName]) lte nRightValue   ) { 
							lstError = listAppend(lstError,nRow,","); 
						}

					} else { 
					
						if (NOT isNumeric(mid(ruletype,8,1))) {
							sComp = mid(ruletype,7,2);  
							nLength = mid(ruletype,9,len(ruletype));
						} else {
							sComp = mid(ruletype,7,1);
							nLength = mid(ruletype,8,len(ruletype));
						}
					
						//writedump(sComp); 
						//writedump(arguments.form[variables.fieldName]);
					
						if (structKeyExists(arguments.form, "#variables.fieldName#")) {
							
							switch(sComp) {
															
								case ">":
									if (len(arguments.form[variables.fieldName]) lte nLength ) { lstError = listAppend(lstError,nRow,","); }
								break;	
		
								case "<":
									if (len(arguments.form[variables.fieldName]) gte nLength ) { lstError = listAppend(lstError,nRow,","); }
								break;	
	
								case ">=":
									if (len(arguments.form[variables.fieldName]) lt nLength ) { lstError = listAppend(lstError,nRow,","); }
								break;	
		
								case "<=":
									if (len(arguments.form[variables.fieldName]) gt nLength ) { lstError = listAppend(lstError,nRow,","); }
								break;
		
								case "=":
									if (len(arguments.form[variables.fieldName]) neq nLength ) { lstError = listAppend(lstError,nRow,","); }
								break;	
							} 

						}	

					}
				} 


				if (left(ruletype,5) eq "range") {
				// this tests to see if the value of the field is within the limits of the range provided 
					bMatch = true;
					
					variables.fieldName = listGetAt(arguments.rules[nRow],2,",");
				
					if (findNoCase('-',ruletype,1)) {
					// if in here, field must be is between lengths	
					
						sRuleType 	= replaceNoCase(ruletype,'range','','all');
						sRuleType 	= replaceNoCase(ruletype,'=','','all');
					
						nLeftValue 	= listGetAt(sRuleType,1,'-');		
						nRightValue = listGetAt(sRuleType,2,'-');
					
						if (arguments.form[variables.fieldName] gte nLeftValue AND arguments.form[variables.fieldName] lte nRightValue   ) { 
							lstError = listAppend(lstError,nRow,","); 
						}

					} else {

						if (NOT isNumeric(mid(ruletype,7,1))) {
							sComp = mid(ruletype,6,2);  
							nValue = mid(ruletype,8,len(ruletype));
						} else {
							sComp = mid(ruletype,6,1);
							nValue = mid(ruletype,7,len(ruletype));
						}
						
						/* writedump(sComp); 
						   writedump(arguments.form[variables.fieldName]); */
					
						if (structKeyExists(arguments.form, "#variables.fieldName#")) {
							
							switch(sComp) {
															
								case ">":
									if ( arguments.form[variables.fieldName] lte nValue ) { lstError = listAppend(lstError,nRow,","); 
									}
								break;	
		
								case "<":
									if ( arguments.form[variables.fieldName] gte nValue ) { lstError = listAppend(lstError,nRow,","); }
								break;	
	
								case ">=":
									if (arguments.form[variables.fieldName] lt nValue ) { lstError = listAppend(lstError,nRow,","); }
								break;	
		
								case "<=":
									if (arguments.form[variables.fieldName] gt nValue ) { lstError = listAppend(lstError,nRow,","); }
								break;
		
								case "=":
									if ( arguments.form[variables.fieldName] neq nValue ) { lstError = listAppend(lstError,nRow,","); }
								break;	
							} 

						}	

					} 
					
				}	
				
				
				/* In case the rule entered is not a rule we need to advise the user */
				if (NOT bMatch) {
					arrayAppend(arrValidate, structNew());
					arrValidate[arrayLen(arrValidate)].fieldName	= ruleType; 
					arrValidate[arrayLen(arrValidate)].error		= 'The rule type you submitted in your rules does not exist';
				}

				</cfscript>
				
			</cfloop>

			<cfif listLen(lstError,",")>
			
				<cfloop list="#lstError#" index="nRow">
					<cfscript>
						arrayAppend(arrValidate, structNew());
						arrValidate[arrayLen(arrValidate)].fieldName	= listGetAt(arguments.rules[nRow],2,",");
						arrValidate[arrayLen(arrValidate)].error		= listGetAt(arguments.rules[nRow],3,",");
					</cfscript>			
				</cfloop>
				
			</cfif>	
			
		<cfelse>

			<cfscript>
				arrayAppend(arrValidate, structNew());
				arrValidate[arrayLen(arrValidate)].fieldName	= 'noRules'; 
				arrValidate[arrayLen(arrValidate)].error		= 'There were no validation rules sent to the form validation function';
			</cfscript>

		</cfif>	
		
		<cfreturn arrValidate >

	</cffunction>

</cfcomponent>
