all:
	docker compose -f ./srcs/docker-compose.yml up -d --build

down:
	docker compose -f ./srcs/docker-compose.yml down

re: clean prune all

clean:
	docker compose -f ./srcs/docker-compose.yml down -v --rmi all --remove-orphans

prune:
	docker system prune -f

.PHONY: all re down clean prune