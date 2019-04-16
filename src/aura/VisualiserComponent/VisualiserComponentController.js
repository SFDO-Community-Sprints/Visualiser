({
    doInit : function(component, event, helper) {
        var action = component.get("c.Get_Tags");
        action.setParams({"recID":component.get("v.recordId"), 
                          "currentObject":component.get("v.sobjecttype")});
        action.setCallback(this, function(response) {
            //alert('Loading initiated');
            var state = response.getState();
            if (component.isValid() && state == "SUCCESS") {
                var return_tags = response.getReturnValue();
                if (return_tags != null) {
                    component.set("v.tags", return_tags);
                }
            }
        });
        $A.enqueueAction(action);
	},
})