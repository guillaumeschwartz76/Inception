.PHONY: up

SRCS_DIR = ./srcs

up:
	@cd $(SRCS_DIR) && sudo docker compose up --build -d --force-recreate

down:
	@cd $(SRCS_DIR) && sudo docker compose down
ps:
	@cd $(SRCS_DIR) && sudo docker compose ps

clean:
	@cd $(SRCS_DIR) && sudo docker compose down --volumes --remove-orphans

fclean: clean
	@sudo docker system prune -af
	@sudo docker volume prune -f 

re: fclean up

logs:
	@cd $(SRCS_DIR) && sudo docker compose logs -f
