function(doc) {
  if(doc.type == "charge") {
    emit([doc.merchant], null);
  }
}
