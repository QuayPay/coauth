function(doc) {
  if(doc.type == "coauth_authentication") {
    emit([doc.user_id], null);
  }
}
