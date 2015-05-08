function(doc) {
    if(doc.type === "strat") {
        emit(doc.name, null);
    }
}
