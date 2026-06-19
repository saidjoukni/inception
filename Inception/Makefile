NAME		:= inception
COMPOSE		:= docker compose -p $(NAME) -f srcs/docker-compose.yml
DATA_DIR	:= /home/$(USER)/data
DB_DATA		:= $(DATA_DIR)/mariadb
WP_DATA		:= $(DATA_DIR)/wordpress
PORTAINER_DATA	:= $(DATA_DIR)/portainer

.PHONY: all prepare up build down stop restart logs ps clean fclean re

all: up

prepare:
	mkdir -p $(DB_DATA) $(WP_DATA) $(PORTAINER_DATA)

up: prepare
	$(COMPOSE) up --build -d

build: prepare
	$(COMPOSE) build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

restart: down up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

clean:
	$(COMPOSE) down --remove-orphans

fclean:
	$(COMPOSE) down -v --remove-orphans
	if [ -d "$(DATA_DIR)" ]; then docker run --rm -v $(DATA_DIR):/data debian:bookworm sh -c 'rm -rf /data/*'; rm -rf $(DATA_DIR); fi

re: fclean all
