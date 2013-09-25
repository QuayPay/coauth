function(doc) {
  if(doc.type == "card") {
    emit([doc.user_id], null);
  }
}
