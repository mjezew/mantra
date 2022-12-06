function (doc) {
  if (doc.document_type == "block" && doc.todo !== null) {
    const page_id = doc.ancestors[doc.ancestors.length -1]
    emit([page_id, doc.todo.state])
  }
}
