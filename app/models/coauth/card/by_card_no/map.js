function(doc) {
  if(doc.type == "card") {
    emit([doc.cardno], null);
  }
}
