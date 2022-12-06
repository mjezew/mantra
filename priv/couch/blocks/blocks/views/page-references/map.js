function (doc) {
  if (doc.document_type == "block") {
    for (const page of doc.links) {
      emit(page)
    }
  }
}
