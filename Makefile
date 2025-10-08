# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: wedos-sa <marvin@42.fr>                    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/10/06 14:51:33 by wedos-sa          #+#    #+#              #
#    Updated: 2025/10/06 14:52:46 by wedos-sa         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

NAME = pipex.a

CC = cc

CFLAGS = -Wall -Wextra -Werror

SRCS = 	pipex.c			\
		checker_error.c	\
		commands.c		\
		exec_utils.c	\
		exec.c

OBJS = $(SRCS:.c=.o)

RMAKE = make re

all: $(NAME)

all: $(NAME)

$(NAME): $(OBJS)
	cd ./libft && $(RMAKE)
	cp ./libft/libft.a $(NAME)
	ar -rcs $(NAME) $(OBJS)
	cc pipex.c $(NAME) -o pipex

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS)
	cd ./libft && make clean

fclean: clean
	rm -f $(NAME)
	cd ./libft && make fclean
	rm -f pipex

re: fclean all

.PHONY: all clean fclean re
