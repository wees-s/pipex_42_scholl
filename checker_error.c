/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   checker_error.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: wedos-sa <marvin@42.fr>                    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/06 11:12:45 by wedos-sa          #+#    #+#             */
/*   Updated: 2025/10/08 10:35:37 by wedos-sa         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

int	input_checker(int argc, char **argv)
{
	int	i;

	i = 0;
	if (argc != 5)
		return (0);
	if (argv[1][0] == '\0' && argv[2][0] == '\0'
		&& argv[3][0] == '\0' && argv[4][0] == '\0')
		return (1);
	if (argv[3][0] == '\0')
	{
		ft_putstr_fd("Permission denied\n", 1);
		exit(126);
	}
	else if (argv[2][0] == '\0')
	{
		ft_putstr_fd("Permission denied\n", 1);
		exit(0);
	}
	return (1);
}

void	perror_exit(char *s)
{
	perror(s);
	exit(EXIT_FAILURE);
}
