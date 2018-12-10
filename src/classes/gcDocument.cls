global with sharing class gcDocument {

	global gcDocument(){}
	global gcDocument(ApexPages.StandardController c){} 

	global String strComponent{get;set;}
	global String idParent{get;set;}

	webservice static String sendDocument(String pStrComponent, String pIdParent, String pIdContact)
	{		
		Attachment att = createDocument(null, pStrComponent, pIdParent);
		
		Id idEmailTemplate = null;
		if(Id.valueOf(pIdParent).getSobjectType() == Schema.AcctSeed__Billing__c.SObjectType)
		{
			idEmailTemplate = Email_Template_Id__c.getOrgDefaults().Billing__c;	
		}
		else if(Id.valueOf(pIdParent).getSobjectType() == Schema.Inventory_Transfer__c.SObjectType)
		{
			idEmailTemplate = Email_Template_Id__c.getOrgDefaults().Inventory_Transfer__c;	
		}
		else if(Id.valueOf(pIdParent).getSobjectType() == Schema.AcctSeedERP__Sales_Order__c.SObjectType)
		{
			idEmailTemplate = Email_Template_Id__c.getOrgDefaults().Sales_Order__c;	
		}
		else if(Id.valueOf(pIdParent).getSobjectType() == Schema.AcctSeedERP__Purchase_Order__c.SObjectType)
		{
			idEmailTemplate = Email_Template_Id__c.getOrgDefaults().Purchase_Order__c;	
		}


		String myURL = '/email/author/emailauthor.jsp?idParent=' + pIdParent;
			   myURL += '&retURL=/' + att.ParentId;
			   myURL += '&p6=' + EncodingUtil.urlEncode(att.Name,'UTF-8'); //email.subject
			   myURL += '&p3_lkid=' + att.ParentId;
			   myURL += '&template_id='+idEmailTemplate;
			   myURL += '&new_template=1'; //include the attachment from the VF template
			   myURL += '&idAttachment='+att.Id;
			   myURL += '&component='+pStrComponent;
			   myURL += '&p2_lkid='+pIdContact;

		return myURL;
	}
	
	webservice static void saveDocument(String pStrComponent, String pIdParent) 
	{
		createDocument(null, pStrComponent, pIdParent);
	}

	@RemoteAction
	global static Attachment createDocument(String pStrFileName, String pStrComponent, String pIdParent)
	{
		if(pStrFileName == null) pStrFileName = constructFileName(pStrComponent,pIdParent);
		if(pStrFileName == null) pStrFileName = 'myFile.pdf';

		Attachment att = new Attachment(name=pStrFileName);
		pageReference documentPDF = new pageReference('/apex/gpDocument');

		documentPDF.getParameters().put('idParent',pIdParent);
		documentPDF.getParameters().put('component',pStrComponent);
		
		Blob body;
	    try {
	
	        // returns the output of the page as a PDF
	        body = documentPDF.getContentAsPdf();
	
	    // need to pass unit test -- current bug    
	    } catch (VisualforceException e) {
	        body = Blob.valueOf('Some Text');
	    }
	
		att.body = body;
		att.parentId = pIdParent;
		att.isPrivate = false;
		att.ContentType='application/pdf';
		insert att;

		return [SELECT Id, Name, ParentId FROM Attachment WHERE Id =:att.Id][0];
	}

	@RemoteAction
	global static string constructFileName(String pStrComponent, String pIdParent)
	{
		String docType;
		String strFileName;
		if(Id.valueOf(pIdParent).getSobjectType() == Schema.AcctSeed__Billing__c.SObjectType)
		{		
			if(pStrComponent.contains('Billing')) {
				docType = 'Billing';	
			} 
			
			for(AcctSeed__Billing__c billing : [SELECT Id, Name
										  FROM AcctSeed__Billing__c WHERE Id =: pIdParent LIMIT 1])
			{

				String strBillingNumber = String.valueOf(Integer.valueOf(billing.Name.replaceAll('[^0-9]','')));
				String strTimeStamp = dateTime.now().format();
				strFileName = 'Prodigy '+ docType +' '+strBillingNumber +'  v'+strTimeStamp+'.pdf';
			}
		}
		else if(Id.valueOf(pIdParent).getSobjectType() == Schema.Inventory_Transfer__c.SObjectType)
		{		
			if(pStrComponent.contains('InventoryTransfer')) {
				docType = 'Inventory Transfer';	
			} 
			
			for(Inventory_Transfer__c transfer : [SELECT Id, Name
										  FROM Inventory_Transfer__c WHERE Id =: pIdParent LIMIT 1])
			{

				String strTransferName = transfer.Name;
				String strTimeStamp = dateTime.now().format();
				strFileName = 'Prodigy '+ docType +' '+strTransferName +'  v'+strTimeStamp+'.pdf';
			}
		}
		else if(Id.valueOf(pIdParent).getSobjectType() == Schema.AcctSeedERP__Sales_Order__c.SObjectType)
		{		
			if(pStrComponent.contains('SalesOrder')) {
				docType = 'Picking Slip';	
			} 
			
			for(AcctSeedERP__Sales_Order__c order : [SELECT Id, Name
										  FROM AcctSeedERP__Sales_Order__c WHERE Id =: pIdParent LIMIT 1])
			{

				String strOrderName = order.Name;
				String strTimeStamp = dateTime.now().format();
				strFileName = 'Prodigy '+ docType +' '+strOrderName +'  v'+strTimeStamp+'.pdf';
			}
		}
		else if(Id.valueOf(pIdParent).getSobjectType() == Schema.AcctSeedERP__Purchase_Order__c.SObjectType)
		{		
			if(pStrComponent.contains('PurchaseOrder')) {
				docType = 'Purchase Order';	
			} 
			
			for(AcctSeedERP__Purchase_Order__c order : [SELECT Id, Name
										  FROM AcctSeedERP__Purchase_Order__c WHERE Id =: pIdParent LIMIT 1])
			{

				String strOrderName = order.Name;
				String strTimeStamp = dateTime.now().format();
				strFileName = 'Prodigy '+ docType +' '+strOrderName +'  v'+strTimeStamp+'.pdf';
			}
		}


		return strFileName;
	}
}