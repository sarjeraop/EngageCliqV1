/*
 *  @classname  		: ApexResultSetTest
 *  @author 			: Abhishek Daware
 *  @ param             : none
 *  @description  		: This is class which test the return via any lightning component.

 *  @modificationlog
 *  	#		Date				 Description				Modified By
 *		1.	    22-12-2023			 Added Comments			    sarjerao Pujari
*/
@isTest
public class ApexResultSetTest {

/**
 * @ methodname             : constructorTest.
 * @ author                 : Abhishek Daware.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : This method is used to test constructor of ApexResultSet class.
 * @ return                 : none.
 */    
    @isTest 
    public static void constructorTest(){
        Test.StartTest();
        ApexResultSet arSet = new ApexResultSet();
        Test.StopTest();
    }

/**
 * @ methodname             : paramConstructorTest.
 * @ author                 : Abhishek Daware.
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : This method is used to test the params of constructor.
 * @ return                 : none.
 */     
    @isTest 
    public static void paramConstructorTest(){
        Test.StartTest();
        ApexResultSet arSet = new ApexResultSet(true,'Message');
        Test.StopTest();
    }
}