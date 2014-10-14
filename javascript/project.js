function submitTaskEdit (url, action, successUrl, id){
    if(id == undefined || id == ""){
	id = $("#id").val();
    }
    $.post(url, { action: action,
		  title: $("#title").val(),
		  description: $("#description").val(),
		  parentId: $("#parent-task").val(),
		  dueDate: $("#date").val(),
		  id: id},   
	   function(data){
	       if (data.success){
		   location.replace(successUrl);
	       }else{
		   alert(data.message);
	       }
	   });
}
