variable "project_id" {
  description = "The ID of the project in which to create the Firestore resources."
  type        = string
}

variable "region" {
  description = "The region in which to create the Firestore resources."
  type        = string
}

variable "fields" {
  description = "The fields of the Firestore document."
  type        = map(string)
}
