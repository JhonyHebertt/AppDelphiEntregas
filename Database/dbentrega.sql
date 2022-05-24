-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 23-Maio-2022 às 18:20
-- Versão do servidor: 10.4.21-MariaDB
-- versão do PHP: 7.4.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `dbentrega`
--

-- --------------------------------------------------------

--
-- Estrutura da tabela `remessa`
--

CREATE TABLE `remessa` (
  `ID_REMESSA` int(11) NOT NULL,
  `DESCRICAO` varchar(100) DEFAULT NULL,
  `ORIGEM` varchar(100) DEFAULT NULL,
  `DESTINO` varchar(100) DEFAULT NULL,
  `VALOR` decimal(9,2) DEFAULT NULL,
  `STATUS` char(1) DEFAULT NULL,
  `ORIGEM_LATITUDE` decimal(12,8) DEFAULT NULL,
  `ORIGEM_LONGITUDE` decimal(12,8) DEFAULT NULL,
  `ID_USUARIO` int(11) DEFAULT NULL,
  `DT_CADASTRO` datetime DEFAULT NULL,
  `ID_ENTREGADOR` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Estrutura da tabela `usuario`
--

CREATE TABLE `usuario` (
  `ID_USUARIO` int(11) NOT NULL,
  `NOME` varchar(100) DEFAULT NULL,
  `EMAIL` varchar(100) DEFAULT NULL,
  `SENHA` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `remessa`
--
ALTER TABLE `remessa`
  ADD PRIMARY KEY (`ID_REMESSA`);

--
-- Índices para tabela `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`ID_USUARIO`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `remessa`
--
ALTER TABLE `remessa`
  MODIFY `ID_REMESSA` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de tabela `usuario`
--
ALTER TABLE `usuario`
  MODIFY `ID_USUARIO` int(11) NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
