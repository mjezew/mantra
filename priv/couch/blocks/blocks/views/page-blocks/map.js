function (doc) {
  if (doc.document_type == "block") {
    const page_id = doc.ancestors[doc.ancestors.length -1]
    emit([page_id, doc.ancestors.length, doc.position])
  }
}
