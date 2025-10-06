all:
	docker compose -f ./srcs/docker-compose.yml up -d --build

down:
	docker compose -f ./srcs/docker-compose.yml down

re: down all

clean:
	docker compose -f ./srcs/docker-compose.yml down -v --rmi all --remove-orphans

prune:
	docker system prune -f

.PHONY: all re down clean prune

# docker exec -it mariadb bash
# mysql -uroot -p
# SHOW DATABASES;
# USE 'divalent.42.fr';
# SHOW TABLES;
# SELECT * FROM table_name;
# sudo ss -ltnp | grep ':80'
# curl -v http://divalent.42.fr/ 