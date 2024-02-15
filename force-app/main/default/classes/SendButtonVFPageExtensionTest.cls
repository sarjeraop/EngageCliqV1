/**  
*  @classname           : SendButtonVFPageExtensionTest
*  @author              : Sarjerao Pujari
*  @date                : 03-Nov-2023
*  @description         : This apex class is specially designed to test the SendButtonVFPageExtension class.
*  @modificationlog
*  		#		Date		            Description		      Modified By
*/
@isTest
public class SendButtonVFPageExtensionTest
{
/**
 * @ methodname             : SbcVFPageExtensionTest.
 * @ author                 : Sarjerao Pujari. 
 * @ ObjectReferenced       : None.
 * @ param                  : none.
 * @ description            : this method is used to test the constructor of the apex SendButtonVFPageExtension class.
 * @ return                 : none. 
 */ 
    @isTest
    public static void SbcVFPageExtensionTest()
    {
        Contact testContact = new Contact();
        testContact.LastName='Test Account record' ;
        insert testContact;
        
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(new List<Contact>{testContact});
        sc.setSelected(new List<Contact>{testContact});
        
        Test.StartTest();
        SendButtonVFPageExtension sbcObj = new SendButtonVFPageExtension(sc);
        Test.stopTest();
        system.assertEquals(sbcObj.recIds!=null,true);
        
    }
    
}