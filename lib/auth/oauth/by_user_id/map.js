function(doc) {
    if(doc.type === "oauth") {
        emit(doc.user_id, null);
    }
}
