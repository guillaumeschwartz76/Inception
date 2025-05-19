.PHONY: up clean fclean down ps re

WORDVOLUME := /home/gui/data/wordpress
MARIAVOLUME := /home/gui/data/database

NAME := Inception

SRCS_DIR = ./srcs

up: $(NAME)

$(NAME):
	@mkdir - p $(WORDVOLUME) $(MARIAVOLUME)
	@cd $(SRCS_DIR) && docker compose up --build -d --force-recreate

down:
	@cd $(SRCS_DIR) && docker compose -f down

ps:
	@cd $(SRCS_DIR) && docker compose ps

clean:
	@cd $(SRCS_DIR) && docker compose -f down --volumes --remove-orphans

fclean: clean
	@docker system prune -af --volumes
	@docker volume prune -f
	@sudo rm -rf $(WORDVOLUME) $(MARIAVOLUME)

re: fclean up

logs:
	@cd $(SRCS_DIR) && sudo docker compose logs -f
