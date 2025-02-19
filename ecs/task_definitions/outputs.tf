output "arn" {
  value = aws_ecs_task_definition.this.arn
}

output "name" {
  value = trimsuffix(aws_ecs_task_definition.this.tags.Name, "-task")
}