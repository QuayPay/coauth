function(doc) {
  if(doc.type == "authentication") {
    emit([doc.user_id], null);
  }
}
