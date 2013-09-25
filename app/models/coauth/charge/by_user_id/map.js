function(doc) {
  if(doc.type == "charge") {
    emit([doc.user_id], null);
  }
}
