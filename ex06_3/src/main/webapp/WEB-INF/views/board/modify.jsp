<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
 
<%@include file="../includes/header.jsp" %>
<style>
   .uploadResult {
       width: 100%;
   }

   .uploadResult ul {
       display: flex;
       flex-flow: row;
       justify-content: center;
       align-items: center;
       padding: 0;
   }

   .uploadResult ul li {
       list-style: none;
       padding: 10px;
   }

   .uploadResult ul li img {
       width: 100px;
   }
   
   .uploadResult ul li span {color: dimgray;}
   
   .bigPictureWrapper {
        cursor: pointer;
   		position: fixed;
   		display: none;
   		justify-content: center;
   		align-items: center;
   		top: 0%;
   		width: 100%;
   		height: 100%;
   		z-index: 100;
   		background-color: rgba(0,0,0,0.8);
   }
   .bigPicture {
   		position: relative;
   		display: flex;
   		justify-content: center;
   		align-items: center;
   }
   .bigPicture img {width: 600px;}
</style>
    
<form role="form" action="/board/modify" method="post">

	<input type="hidden" name="${_csrf.parameterName }" value="${_csrf.token }" />
	<input type="hidden" name="pageNum" value='<c:out value="${cri.pageNum }"/>'>
	<input type="hidden" name="amount" value='<c:out value="${cri.amount }"/>'>
	<input type="hidden" name="type" value='<c:out value="${cri.type }"/>'>
	<input type="hidden" name="keyword" value='<c:out value="${cri.keyword }"/>'>
	
	<div class="form-group">
		<label>Bno</label>
		<input class="form-control" name='bno' value='<c:out value="${board.bno }"/>' readonly="readonly">	
	</div>
	<div class="form-group">
		<label>Title</label>
		<input class="form-control" name='title' value='<c:out value="${board.title }"/>'>	
	</div>
	<div class="form-group">
		<label>Text area</label>
		<textarea class="form-control" rows="3" name="content"><c:out value="${board.content }"/></textarea>
	</div>
	<div class="form-group">
		<label>Writer</label>
		<input class="form-control" name='writer' value='<c:out value="${board.writer }"/>' readonly="readonly">	
	</div>
	<div class="form-group">
		<label>RegDate</label>
		<input class="form-control" name='regDate' value='<fmt:formatDate pattern="yyyy/MM/dd" value="${board.regdate }"/>' readonly="readonly">	
	</div>
	<div class="form-group">
		<label>Update Date</label>
		<input class="form-control" name='updateDate' value='<fmt:formatDate pattern="yyyy/MM/dd" value="${board.updateDate }"/>' readonly="readonly">	
	</div>
	
	<sec:authentication property="principal" var="pinfo"/>
	
	<sec:authorize access="isAuthenticated()">
		<c:if test="${pinfo.username eq board.writer }">
			<button type="submit" data-oper='modify' class="btn btn-default">수정</button>
			<button type="submit" data-oper='remove' class="btn btn-danger">삭제</button>
		</c:if>
	</sec:authorize>
		
	<button type="submit" data-oper='list' class="btn btn-info">목록</button>
	
	
<div class='bigPictureWrapper'>
	<div class='bigPicture'>
	</div>
</div>

<div class="row">
	<div class="col-lg-12">		
		<div class="panel panel-default">
		
			<div class="panel-heading">첨부파일</div>
			<div class="panel-body">
				<div class="form-group uploadDiv">
					<input type="file" name='uploadFile' multiple="multiple">
				</div>					
				<div class="uploadResult">
					<ul>
					</ul>
				</div>
			</div>
		
		</div>
	</div>
</div>

<script>
$(document).ready(function() {
	
	(function(){
		
		var bno='<c:out value="${board.bno}"/>';
		
		$.getJSON("/board/getAttachList",{bno:bno},function(arr){
			
			console.log(arr);
			
			var str="";
			
			$(arr).each(function(i,attach){
				
				if(attach.fileType){
					var fileCallPath=encodeURIComponent(attach.uploadPath+"/s_"+attach.uuid+"_"+attach.fileName);
					
					str += "<li data-path='"+attach.uploadPath+"' data-uuid='"+attach.uuid+"' data-filename='"+attach.fileName+"' data-type='"+attach.fileType+"'><div>";
					str += "<span>"+attach.fileName+"</span>";
					str += "<button type='button' data-file=\'"+fileCallPath+"\' data-type='image' class='btn btn-warning btn-circle'><i class='fa fa-times'></i></button><br>";
					str += "<img src='/display?fileName="+fileCallPath+"'>";
					str += "</div></li>";
						 
				}else {	
													
					str += "<li data-path='"+attach.uploadPath+"' data-uuid='"+attach.uuid+"' data-filename='"+attach.fileName+"' data-type='"+attach.fileType+"'><div>";
					str += "<span>"+attach.fileName+"</span>";
					str += "<button type='button' data-file=\'"+fileCallPath+"\' data-type='file' class='btn btn-warning btn-circle'><i class='fa fa-times'></i></button><br>";
					str += "<img src='/resources/img/attach.png'>";
					str += "</div></li>";
				}
			});
			
			$(".uploadResult ul").html(str);
			
		});
	})();
	
	$(".uploadResult").on("click", "button", function(e){
		  
		console.log("delete file");
		   
		   if (confirm("Remove this file?")) {
		      var targetLi = $(this).closest("li");
		      targetLi.remove();
		   }
	}); 
	
	// 업로드 파일 확장자 필터링
	var regex=new RegExp("(.*?)\.(exe|sh)$");
	var maxSize=5242880;	//5MB
	
	function checkExtension(fileName,fileSize){
		if(fileSize>=maxSize){
			alert("파일 사이즈 초과");
			return false;
		}
		
		if(regex.test(fileName)){
			alert("해당 종류의 파일은 업로드할 수 없습니다.");
			return false;
		}
		return true;
	}
	
	var csrfHeaderName = "${_csrf.headerName}";
	var csrfTokenValue = "${_csrf.token}";
	
	$("input[type='file']").change(function(e){
		var formData=new FormData();
		var inputFile=$("input[name='uploadFile']");
		var files=inputFile[0].files;
		
		console.log(files);
		
		for(var i=0;i<files.length;i++){			
			if(!checkExtension(files[i].name,files[i].size)){
				return false;
			}
			formData.append("uploadFile",files[i]);
		}
		
		$.ajax({
			url:'/uploadAjaxAction',
			processData:false,
			contentType:false,
			data:formData,
			type:'POST',
			beforeSend : function(xhr){
				xhr.setRequestHeader(csrfHeaderName,csrfTokenValue);
			},
			dataType:'json',
			success:function(result){
				console.log(result);
				
				showUploadedFile(result);				
			}
		});
	});
	
	function showUploadedFile(uploadResultArr){
		
		if(!uploadResultArr || uploadResultArr.length==0){
			return;
		}
		var uploadUL=$(".uploadResult ul");
		
		var str="";
		
		$(uploadResultArr).each(function(i,obj){
			
			if(obj.image){
				var fileCallPath=encodeURIComponent(obj.uploadPath+"/s_"+obj.uuid+"_"+obj.fileName);
				
				str+="<li data-path='"+obj.uploadPath+"' data-uuid='"+obj.uuid+"' data-filename='"+obj.fileName+"' data-type='"+obj.image+"'><div>"+
					 "		<span>"+obj.fileName+"</span>"+
					 "		<button type='button' data-file=\'"+fileCallPath+"\' data-type='image' class='btn btn-warning btn-circle'><i class='fa fa-times'></i></button><br>"+
					 "		<img src='/display?fileName="+fileCallPath+"'>"+
					 "</div></li>";
			}else{			
				var fileCallPath=encodeURIComponent(obj.uploadPath+"/"+obj.uuid+"_"+obj.fileName);
				
				var fileLink=fileCallPath.replace(new RegExp(/\\/g),"/");
				
				str+="<li data-path='"+obj.uploadPath+"' data-uuid='"+obj.uuid+"' data-filename='"+obj.fileName+"' data-type='"+obj.image+"'><div>"+
					 "		<span>"+obj.fileName+"</span>"+
					 "		<button type='button' data-file=\'"+fileCallPath+"\' data-type='file' class='btn btn-warning btn-circle'><i class='fa fa-times'></i></button><br>"+
					 "		<img src='resources/img/attach.png'>"+obj.fileName+
					 "</div></li>";
			}
		});
		
		uploadUL.append(str);
	}



	function showUploadResult(uploadResultArr) {
	   
	   if (!uploadResultArr || uploadResultArr.length == 0) {return;}
	   
	   var uploadUL = $(".uploadResult ul");
	   var str="";
	   
	   $(uploadResultArr).each(function(i,obj) {
	      if (obj.image) {
	         var fileCallPath = encodeURIComponent(obj.uploadPath + "/s_" + obj.uuid + "_" + obj.fileName);
	         str += "<li data-path='"+obj.uploadPath+"'";
	         str += " data-uuid='"+obj.uuid+"' data-fileName='"+obj.fileName+"'data-type='"+obj.image+"'";
	         str += " ><div>";
	         str += "<span> " + obj.fileName + " </span>";
	         str += "<button type='button' data-file=\'"+fileCallPath+"\' data-type='image' "
	         str += "class='btn btn-warning btn-circle'><i class='fa fa-times'></i></button><br>";
	         str += "<img src='/display?fileName=" + fileCallPath + "'>";
	         str += "</div>";
	         str += "</li>";
	      } else {
	         var fileCallPath = encodeURIComponent(obj.uploadPath + "/" + obj.uuid + "_" + obj.fileName);
	         var fileLink = fileCallPath.replace(new RegExp(/\\/g), "/");
	         str += "<li data-path='"+obj.uploadPath+"'";
	         str += " data-uuid='"+obj.uuid+"' data-fileName='"+obj.fileName+"'data-type='"+obj.image+"'";
	         str += " ><div>";
	         str += "<span> " + obj.fileName + " </span>";
	         str += "<button type='button' data-file=\'"+fileCallPath+"\' data-type='file' "
	         str += "class='btn btn-warning btn-circle'><i class='fa fa-times'></i></button><br>";
	         str += "<img src='/resources/img/attachment.png'></a>";
	         str += "</div>";
	         str += "</li>";
	      }
	   });
	   
	   uploadUL.append(str);
	}
	
	var formObj = $("form");

	$('button').on("click", function(e){
	   
	   e.preventDefault();  //전송을 막음
	   var operation = $(this).data("oper");
	   console.log(operation);
	   
	   if (operation === 'remove') {
	      formObj.attr("action", "/board/remove");
	   } else if (operation === 'list') {
	      /* move to list */
	      /* location.href = "/board/list"; */
	      
	      formObj.attr("action","/board/list").attr("method","get");
	      
	      var pageNumTag = $("input[name='pageNum']").clone();
	      var amountTag = $("input[name='amount']").clone();
	      var keywordTag = $("input[name='keyword']").clone();
	      var typeTag = $("input[name='type']").clone();
	      
	      formObj.empty();
	      
	      formObj.append(pageNumTag);
	      formObj.append(amountTag);
	      formObj.append(keywordTag);
	      formObj.append(typeTag);

	     // 추가
	   } else if (operation === 'modify') {
	      console.log("submit clicked");
	      
	      var str = "";
	      
	      $(".uploadResult ul li").each(function(i,obj){
	         var jobj = $(obj);
	         console.dir(jobj);
	         
	         str += "<input type='hidden' name='attachList["+i+"].fileName' value='"+jobj.data("filename")+"'>";
	         str += "<input type='hidden' name='attachList["+i+"].uuid' value='"+jobj.data("uuid")+"'>";
	         str += "<input type='hidden' name='attachList["+i+"].uploadPath' value='"+jobj.data("path")+"'>";
	         str += "<input type='hidden' name='attachList["+i+"].fileType' value='"+jobj.data("type")+"'>";
	      });
	      formObj.append(str).submit();
	   }

	   formObj.submit();  //폼 전송
	});

});
</script>

	<script type="text/javascript">
	    $(document).ready(function() {
	    	
	    	
	    	
	       var formObj = $("form");
	       
	      $('button').on("click",function(e){
	    	 
	    	  e.preventDefault();
	    	  
	    	  var operation = $(this).data("oper");
	    	  
	    	  console.log(operation);
	    	  
	    	  if(operation === 'remove'){
	    		  
	    		  formObj.attr("action","/board/remove");
	    		  
	    	  } else if(operation === 'list'){
	    		  
	    		  formObj.attr("action","/board/list").attr("method","get");
	    		  
	    		  var pageNumTag=$("input[name='pageNum']").clone();
	    		  var amountTag=$("input[name='amount']").clone();
	    		  var keywordTag=$("input[name='keyword']").clone();
	    		  var typeTag=$("input[name='type']").clone();
	    		 	<input type="hidden" name="pageNum" value='<c:out value="${cri.pageNum }"/>'>
	    			<input type="hidden" name="amount" value='<c:out value="${cri.amount }"/>'>
	    			<input type="hidden" name="type" value='<c:out value="${cri.type }"/>'>
	    			<input type="hidden" name="keyword" value='<c:out value="${cri.keyword }"/>'>
	    		  formObj.empty();
	    		  
	    		  formObj.addend(pageNumTag);
	    		  formObj.addend(amountTag);
	    		  formObj.addend(keywordTag);
	    		  formObj.addend(typeTag);
	    	  }
	    	  formObj.submit();
	    	  
	      });
	    });
	
	</script>


</form>
<%@include file="../includes/footer.jsp" %>
