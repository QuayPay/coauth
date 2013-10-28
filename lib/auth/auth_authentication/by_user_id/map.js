function(doc) {
  if(doc.type == "auth_authentication") {
    emit([doc.user_id], null);
  }
}
