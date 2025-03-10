variable "num_cpus" {
  description = "The number of CPUs"
  type        = number
  default     = 1
}

variable "num_cores_per_socket" {
  description = "The number of cores per socket"
  type        = number
  default     = 2
}

variable "memory" {
  description = "The amount of memory in MB"
  type        = number
  default     = 2048
}

